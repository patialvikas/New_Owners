import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/requests/delivery_address.request.dart';
import 'package:fuodz/view_models/delivery_address/base_delivery_addresses.vm.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/translations/delivery_address/edit_delivery_address.i18n.dart';

class EditDeliveryAddressesViewModel extends BaseDeliveryAddressesViewModel {
  //
  DeliveryAddressRequest deliveryAddressRequest = DeliveryAddressRequest();
  TextEditingController nameTEC = TextEditingController();
  TextEditingController addressTEC = TextEditingController();
  TextEditingController descriptionTEC = TextEditingController();
  bool isDefault = false;
  DeliveryAddress deliveryAddress;

  //
  EditDeliveryAddressesViewModel(BuildContext context, this.deliveryAddress) {
    this.viewContext = context;
  }

  //
  void initialise() {
    //
    nameTEC.text = deliveryAddress.name;
    addressTEC.text = deliveryAddress.address;
    descriptionTEC.text = deliveryAddress.description;
    isDefault = deliveryAddress.isDefault == 1;
    notifyListeners();
  }

  //
  showAddressLocationPicker() async {
    LocationResult locationResult = await showLocationPicker(
      viewContext,
      AppStrings.googleMapApiKey,
      language: I18n.language,
      countries: [AppStrings.countryCode],
    );

    if (locationResult != null) {
      addressTEC.text = locationResult.address;
      deliveryAddress.address = locationResult.address;
      deliveryAddress.latitude = locationResult.latLng.latitude;
      deliveryAddress.longitude = locationResult.latLng.longitude;
      // From coordinates
      setBusy(true);
      deliveryAddress = await getLocationCityName( deliveryAddress );
      setBusy(false);
      notifyListeners();
    }
  }

  void toggleDefault(bool value) {
    isDefault = value;
    deliveryAddress.isDefault = isDefault ? 1 : 0;
    notifyListeners();
  }

  //
  updateDeliveryAddress() async {
    if (formKey.currentState.validate()) {
      //
      deliveryAddress.name = nameTEC.text;
      deliveryAddress.description = descriptionTEC.text;
      //
      setBusy(true);
      //
      final apiRespose = await deliveryAddressRequest.updateDeliveryAddress(
        deliveryAddress,
      );

      //
      CoolAlert.show(
        context: viewContext,
        type: apiRespose.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "Update Delivery Address".i18n,
        text: apiRespose.message,
        onConfirmBtnTap: () {
          viewContext.pop();
          viewContext.pop(true);
        },
      );
      //
      setBusy(false);
    }
  }
}
