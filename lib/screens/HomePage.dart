import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Member {
  const Member({required this.name, required this.email});

  final String name;
  final String email;
}

class ConversationMessage {
  const ConversationMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isPlatformMessage,
  });

  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isPlatformMessage;
}

class _HomePageState extends State<HomePage> {
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  final List<Member> _registeredMembers = const [
    Member(name: 'Alice Johnson', email: 'alice@domain.com'),
    Member(name: 'Bob Smith', email: 'bob@domain.com'),
    Member(name: 'Carla Rivera', email: 'carla@domain.com'),
    Member(name: 'David Kim', email: 'david@domain.com'),
  ];

  late final Map<String, List<ConversationMessage>> _conversations;

  @override
  void initState() {
    super.initState();
    _conversations = {
      for (final member in _registeredMembers)
        member.email: [
          ConversationMessage(
            sender: member.name,
            message: 'Hello, I am available for updates.',
            timestamp: DateTime.now().subtract(const Duration(hours: 8)),
            isPlatformMessage: false,
          ),
        ]
    };
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _sendMailToAllMembers() {
    if (_subjectController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both subject and message body.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();

    setState(() {
      for (final member in _registeredMembers) {
        _conversations[member.email]!.add(
          ConversationMessage(
            sender: 'Platform',
            message: 'Subject: $subject\n$body',
            timestamp: now,
            isPlatformMessage: true,
          ),
        );

        _conversations[member.email]!.add(
          ConversationMessage(
            sender: member.name,
            message:
                'Received your mail about "$subject". Thanks for the update.',
            timestamp: now.add(const Duration(minutes: 1)),
            isPlatformMessage: false,
          ),
        );
      }
    });

    _subjectController.clear();
    _bodyController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mail sent to ${_registeredMembers.length} registered members.',
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Member Mail & Conversations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Mail subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mail body',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendMailToAllMembers,
                icon: const Icon(Icons.send),
                label: const Text('Send mail to all registered members'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _registeredMembers.length,
                itemBuilder: (context, index) {
                  final member = _registeredMembers[index];
                  final messages = _conversations[member.email]!;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Text(member.name),
                      subtitle: Text(member.email),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Column(
                            children: messages
                                .map(
                                  (message) => Align(
                                    alignment: message.isPlatformMessage
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: message.isPlatformMessage
                                            ? Colors.blue.shade50
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.sender,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(message.message),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatTimestamp(message.timestamp),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
