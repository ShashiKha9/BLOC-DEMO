import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:rescu_organization_portal/data/blocs/group_address_bloc.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/dto/group_address_dto.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';

import '../../../data/services/address/address_service.dart';
import '../../../data/services/address/address_service_result.dart';
import '../../../data/services/service_response.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/custom_colors.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/spacer_size.dart';
import '../../widgets/text_input_decoration.dart';

class AddUpdateGroupAddressModelState extends BaseModalRouteState {
  final String groupId;
  final GroupAddressDto? address;

  AddUpdateGroupAddressModelState(this.groupId, {this.address});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _countyController = TextEditingController();
  final TextEditingController _crossStreetController = TextEditingController();

  String? _selectedState;
  final dropdownState = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    if (address != null && address!.id != null) {
      _addressController.text = address!.address1;
      _address2Controller.text = address!.address2 ?? "";
      _cityController.text = address!.city;
      _zipCodeController.text = address!.zipCode;
      _nicknameController.text = address!.name;
      _countyController.text = address!.county ?? "";
      _crossStreetController.text = address!.crossStreet ?? "";
      _selectedState = address!.state;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _nicknameController.dispose();
    _countyController.dispose();
    _crossStreetController.dispose();
    super.dispose();
  }

  @override
  Widget content(BuildContext context) {
    return BlocListener(
      bloc: context.read<AddUpdateGroupAddressBloc>(),
      listener: (context, state) {
        if (state is GroupAddressLoadingState) {
          showLoader();
        } else {
          hideLoader();
          if (state is GroupAddressErrorState) {
            ToastDialog.error(MessagesConst.internalServerError);
          }
          if (state is AddressAddedSuccessState) {
            ToastDialog.success("Address added successfully");
            Navigator.of(context).pop();
          }
          if (state is AddressUpdatedSuccessState) {
            ToastDialog.success("Address updated successfully");
            Navigator.of(context).pop();
          }
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration:
                      TextInputDecoration(labelText: "Address Nickname"),
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  controller: _nicknameController,
                  validator: (value) {
                    value = value?.trim();
                    if (value?.isEmpty ?? false) {
                      return 'Please enter Address Nickname.';
                    }
                    return null;
                  },
                  maxLength: MAX_LENGTH_ADDRESS_NICKNAME,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                ),
                SpacerSize.at(1.5),
                TypeAheadFormField(
                    hideOnLoading: true,
                    hideOnEmpty: true,
                    hideOnError: true,
                    suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                      color: Colors.white,
                    ),
                    textFieldConfiguration: TextFieldConfiguration(
                        decoration: TextInputDecoration(labelText: "Address 1"),
                        controller: _addressController),
                    suggestionsCallback: (pattern) async {
                      if (pattern.length > MIN_LENGTH_ADDRESS_1_AUTOCOMPLETE) {
                        var result =
                            await context.read<IAddressService>().find(pattern);
                        if (result is SuccessDataResponse<
                            List<AddressServiceResult>>) {
                          return result.result;
                        }
                      }
                      return <AddressServiceResult>[];
                    },
                    onSuggestionSelected: (AddressServiceResult val) async {
                      var detail =
                          await context.read<IAddressService>().get(val.id);
                      if (detail is SuccessDataResponse<AddressServiceDetail>) {
                        setState(() {
                          _addressController.text = detail.result.street ?? "";
                          _address2Controller.text =
                              detail.result.street2 ?? "";
                          _cityController.text = detail.result.city ?? "";
                          _selectedState = detail.result.state;
                          _zipCodeController.text = detail.result.zipCode ?? "";
                          _countyController.text = detail.result.county ?? "";
                          _crossStreetController.text = "";
                        });
                        dropdownState.currentState!
                            .didChange(detail.result.state);
                      }
                    },
                    onSaved: (v) {},
                    itemBuilder: (context, AddressServiceResult suggestion) {
                      return Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            suggestion.name,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                    validator: (value) {
                      value = value?.trim();
                      if (value?.isEmpty ?? false) {
                        return 'Please enter valid Address.';
                      }
                      if (value!.length > MAX_LENGTH_ADDRESS_1) {
                        return 'Please enter valid Address.';
                      }
                      return null;
                    }),
                SpacerSize.at(1.5),
                TextFormField(
                  decoration: TextInputDecoration(labelText: "Address 2"),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  controller: _address2Controller,
                  maxLength: MAX_LENGTH_ADDRESS_2,
                  validator: (value) {
                    value = value?.trim();
                    if (value!.isNotEmpty &&
                        value.length < MIN_LENGTH_ADDRESS_2) {
                      return 'Please enter valid Address.';
                    }
                    return null;
                  },
                ),
                SpacerSize.at(1.5),
                TextFormField(
                  decoration: TextInputDecoration(labelText: "City"),
                  validator: (value) {
                    value = value?.trim();
                    if (value?.isEmpty ?? false) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  controller: _cityController,
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                ),
                SpacerSize.at(1.5),
                TextFormField(
                  decoration: TextInputDecoration(labelText: "County"),
                  validator: (value) {
                    value = value?.trim();
                    if (value?.isEmpty ?? false) {
                      return 'Please enter your County';
                    }
                    return null;
                  },
                  maxLength: MAX_LENGTH_ADDRESS_COUNTY,
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  controller: _countyController,
                ),
                SpacerSize.at(1.5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FutureBuilder(
                        future: DefaultAssetBundle.of(this.context)
                            .loadString('assets/content/states.json'),
                        builder: (ctx, future) {
                          if (future.connectionState != ConnectionState.done) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          var states =
                              jsonDecode(future.data.toString()).keys.toList();
                          return Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: AppColor.baseBackground,
                            ),
                            child: DropdownButtonFormField(
                                key: dropdownState,
                                onChanged: (dynamic v) {
                                  _selectedState = v;
                                },
                                decoration:
                                    TextInputDecoration(labelText: "State"),
                                validator: (String? value) {
                                  if (_selectedState == null ||
                                      _selectedState!.isEmpty) {
                                    return 'Please select your state';
                                  }
                                  return null;
                                },
                                isExpanded: true,
                                value: _selectedState,
                                items:
                                    states.map<DropdownMenuItem<String>>((k) {
                                  return DropdownMenuItem<String>(
                                      value: k, child: Text(k));
                                }).toList()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _zipCodeController,
                        decoration: TextInputDecoration(labelText: "Zip"),
                        validator: (value) {
                          if (value?.isEmpty ?? false) {
                            return 'Please enter your Zip';
                          }
                          if (value!.length != MAX_LENGTH_ZIP_CODE) {
                            return 'Please enter valid Zip';
                          }
                          return null;
                        },
                        maxLength: MAX_LENGTH_ZIP_CODE,
                        autocorrect: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
                SpacerSize.at(1.5),
                TextFormField(
                  decoration: TextInputDecoration(labelText: "Cross Street"),
                  validator: (value) {
                    value = value?.trim();
                    if (value?.isEmpty ?? false) {
                      return 'Please enter your Cross Street';
                    }
                    return null;
                  },
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  controller: _crossStreetController,
                  maxLength: MAX_LENGTH_CROSS_STREET,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [
      AdaptiveItemAction("SAVE", const Icon(Icons.save), () async {
        if (!_formKey.currentState!.validate()) return;
        FocusScope.of(context).unfocus();
        var addAddress = GroupAddressDto(
            address1: _addressController.text,
            city: _cityController.text,
            isDefault: address?.isDefault ?? false,
            name: _nicknameController.text,
            state: _selectedState!,
            zipCode: _zipCodeController.text,
            address2: _address2Controller.text,
            county: _countyController.text,
            crossStreet: _crossStreetController.text,
            id: address?.id);
        if (address != null && address!.id != null) {
          // context.read<AddUpdateGroupAddressBloc>().add(
          //     UpdateGroupIncidentAddress(groupId, address!.id!, addAddress));
        } else {
          context
              .read<AddUpdateGroupAddressBloc>()
              .add(AddGroupIncidentAddress(groupId, addAddress));
        }
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return address == null ? "Add Address" : "Update Address";
  }
}

// ignore: constant_identifier_names
const int MIN_LENGTH_ADDRESS_2 = 3;
// ignore: constant_identifier_names
const int MAX_LENGTH_ADDRESS_2 = 50;
// ignore: constant_identifier_names
const int MIN_LENGTH_ADDRESS_1_AUTOCOMPLETE = 2;
// ignore: constant_identifier_names
const int MAX_LENGTH_ADDRESS_1 = 50;
// ignore: constant_identifier_names
const int MIN_LENGTH_PERMIT_NEEDED = 3;
// ignore: constant_identifier_names
const int MAX_LENGTH_ZIP_CODE = 5;
// ignore: constant_identifier_names
const int MAX_LENGTH_PERMIT = 30;
// ignore: constant_identifier_names
const int MAX_LENGTH_CROSS_STREET = 35;
// ignore: constant_identifier_names
const int MAX_LENGTH_CITY = 50;
// ignore: constant_identifier_names
const int MAX_LENGTH_ADDRESS_NICKNAME = 50;
// ignore: constant_identifier_names
const int MAX_LENGTH_ADDRESS_COUNTY = 50;
