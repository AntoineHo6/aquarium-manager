import 'package:aquarium_bleu/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddParamValAlertDialog extends StatefulWidget {
  const AddParamValAlertDialog({super.key});

  @override
  State<AddParamValAlertDialog> createState() => _AddParamValAlertDialogState();
}

class _AddParamValAlertDialogState extends State<AddParamValAlertDialog> {
  late TextEditingController _valueFieldController;
  bool _isValueValid = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _valueFieldController = TextEditingController();
  }

  @override
  void dispose() {
    _valueFieldController.dispose();
    super.dispose();
  }

  void _handleAdd(BuildContext context) {
    String valueModified = _valueFieldController.text.trim();

    // Determine the right error message to show for the name.
    // Otherwise, create the tank.
    // if (nameModified.isEmpty) {
    //   setState(() {
    //     _isValueValid = false;
    //     _errorText = AppLocalizations.of(context).emptyName;
    //   });
    // } else if (widget.tankNames.contains(nameModified)) {
    //   setState(() {
    //     _isNameValid = false;
    //     _errorText = AppLocalizations.of(context).nameAlreadyExists;
    //   });
    // } else {
    //   Provider.of<CloudFirestoreProvider>(context, listen: false)
    //       .createTank(_nameFieldController.text, _isFreshwater!);
    //   Navigator.pop(context);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).addParameterValue,
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            MyTextField(
              controller: _valueFieldController,
              isFieldValid: _isValueValid,
              hintText:
                  "${AppLocalizations.of(context).value} (${AppLocalizations.of(context).required})",
              maxLength: 10,
              errorText: _errorText,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(AppLocalizations.of(context).add),
          onPressed: () => _handleAdd(context),
        ),
      ],
    );
  }
}
