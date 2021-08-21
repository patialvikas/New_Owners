import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/view_models/vendor/categories.vm.dart';
import 'package:fuodz/widgets/custom_grid_view.dart';
import 'package:fuodz/widgets/list_items/category.list_item.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/translations/vendor/vendor_type_view.i18n.dart';

class VendorTypeCategories extends StatefulWidget {
  const VendorTypeCategories(
    this.vendorType, {
    this.title,
    this.description,
    Key key,
  }) : super(key: key);

  //
  final VendorType vendorType;
  final String title;
  final String description;
  @override
  _VendorTypeCategoriesState createState() => _VendorTypeCategoriesState();
}

class _VendorTypeCategoriesState extends State<VendorTypeCategories> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CategoriesViewModel>.reactive(
      viewModelBuilder: () =>
          CategoriesViewModel(context, vendorType: widget.vendorType),
      onModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return VStack(
          [
            //
            HStack(
              [
                VStack(
                  [
                    (widget.title != null
                            ? widget.title
                            : "We are here for you")
                        .i18n
                        .text
                        .xl
                        .medium
                        .make(),
                    (widget.description != null
                            ? widget.description
                            : "How can we help?")
                        .i18n
                        .text
                        .xl2
                        .semiBold
                        .make(),
                  ],
                ).expand(),
                //
                (!isOpen ? "See all" : "Show less")
                    .i18n
                    .text
                    .color(AppColor.primaryColor)
                    .make()
                    .onInkTap(() {
                  setState(() {
                    isOpen = !isOpen;
                  });
                }),
              ],
            ).p12(),

            //categories list
            CustomGridView(
              // scrollDirection: Axis.horizontal,
              noScrollPhysics: true,
              padding: EdgeInsets.symmetric(horizontal: 10),
              dataSet: (!isOpen && model.categories.length > 6)
                  ? model.categories.sublist(0, 6)
                  : model.categories,
              isLoading: model.isBusy,
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              itemBuilder: (context, index) {
                //
                return CategoryListItem(
                  category: model.categories[index],
                  onPressed: model.categorySelected,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
