import 'package:chat_app/providers/user_chat_group_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class NewChatGroup extends ConsumerStatefulWidget {
  const NewChatGroup({super.key});

  @override
  ConsumerState<NewChatGroup> createState() {
    return _NewChatGroup();
  }
}

class _NewChatGroup extends ConsumerState<NewChatGroup> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _isSending = false;
  var _isDone = false;

  void _saveItem() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isSending = true;
      });

      ref.read(userChatGroupsProvider.notifier).addNewGroup(_enteredName);

      setState(() {
        _isDone = true;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );

      setState(() {
        _isDone = false;
        _isSending = false;
      });
    }

    if (_isDone) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
              child: Column(
                children: [
                  Text(
                    'Add new chat group',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          maxLength: 25,
                          decoration: const InputDecoration(
                            label: Text('Group name'),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length <= 1 ||
                                value.trim().length > 25) {
                              return 'Must be between 1 and 25 characters.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredName = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              onPressed: _isSending ? null : _saveItem,
                              child: _isSending
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(),
                                    )
                                  : Text(
                                      'Add Item',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer),
                                    ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
