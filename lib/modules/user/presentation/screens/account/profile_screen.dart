import 'package:alert_her/core/comman_widgets/network_status.dart';
import 'package:alert_her/core/comman_widgets/normal_text_field.dart';
import 'package:alert_her/core/comman_widgets/primary_button.dart';
import 'package:alert_her/core/comman_widgets/text_heading.dart';
import 'package:alert_her/core/comman_widgets/text_sub_heading.dart';
import 'package:alert_her/core/constants/const_images.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/services/snackbar_manager.dart';
import 'package:alert_her/core/utils/sb.dart';
import 'package:alert_her/localizations/app_localizations.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/home_view_model.dart';
import 'package:alert_her/modules/user/presentation/widgets/country_picker_widget.dart';
import 'package:alert_her/modules/user/presentation/widgets/custom_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setProfile();
    });
  }



  Future<void> setProfile() async {
    final homeVM = Provider.of<HomeViewModel>(context, listen: false);
    homeVM.resetProfileValues();
    homeVM.setProfileData(context);
    await homeVM.getNationality(context);
    await homeVM.getProfile(context);

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.white,
        body: Consumer<HomeViewModel>(
            builder: (mContext, homeVM, child) {
              print("gender:::: ${homeVM.genderController.text}");
              print("national:::: ${homeVM.nationalityController.text}");
              print("gender1:::: ${homeVM.selectedGender}");
              print("national1:::: ${homeVM.selectedNationality}");
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: MyColors.primaryLight,
                      padding:
                      const EdgeInsets.only(top: 25, left: 17, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: ()=> Navigator.of(context).pop(),
                            child: SvgPicture.asset(
                              ConstImages.backArrow,
                              height: 28,
                              width: 28,
                            ),
                          ),
                          SB.w(20),
                          TextHeading(
                            text: AppLocalizations.of(context).translate('profile'),
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: MyColors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding:
                      const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //by d.j
                            /*
                            TextSubHeading(text: AppLocalizations.of(context).translate('enterUsername'),fontSize: 13,fontWeight: FontWeight.w400,color: MyColors.blackLight,),
                            SB.h(10),
                            NormalTextField(
                              height: 50,
                              controller: homeVM.usernameController,
                              hintText: AppLocalizations.of(context).translate('enterUsername'),
                              inputType: TextInputType.text,
                              isEnabled: false,
                              disableColor: MyColors.primaryLight,
                              disableTextColor: MyColors.black,
                            ),
                            SB.h(15),
                            */
                            TextSubHeading(text: AppLocalizations.of(context).translate('email'),fontSize: 13,fontWeight: FontWeight.w400,color: MyColors.blackLight,),
                            SB.h(10),
                            NormalTextField(
                              height: 50,
                              controller: homeVM.emailController,
                              hintText: AppLocalizations.of(context).translate('enterRegisteredEmail'),
                              inputType: TextInputType.text,
                              isEnabled: false,
                              disableColor: MyColors.primaryLight,
                              disableTextColor: MyColors.black,
                            ),
                            SB.h(15),
                            TextSubHeading(text: AppLocalizations.of(context).translate('phoneNo'),fontSize: 13,fontWeight: FontWeight.w400,color: MyColors.blackLight,),
                            SB.h(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CountryPickerWidget(
                                  initialCode: homeVM.selectedCountryCode,
                                  isEnable: false,
                                  onCountrySelected: (String code) {},
                                ),

                                SB.w(12),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    child: NormalTextField(
                                      controller: homeVM.mobileNumberController,
                                      hintText: AppLocalizations.of(context)
                                          .translate('enter10DigitPhoneNo'),
                                      inputType: TextInputType.phone,
                                      isEnabled: false,
                                      fillColor: MyColors.white,
                                        disableColor: MyColors.primaryLight,
                                        disableTextColor: MyColors.black,
                                      iconPath: ConstImages.greenCheck,
                                        iconSpaceFromTop:13,
                                        iconSpaceFromBottom:13
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SB.h(15),
                            // TextSubHeading(text: AppLocalizations.of(context).translate('gender'),fontSize: 13,fontWeight: FontWeight.w400,color: MyColors.blackLight,),
                            // SB.h(10),
                            // (homeVM.selectedGender == "" || homeVM.selectedGender == AppLocalizations.of(context).translate('selectGender')) ?
                            // CustomSpinner(
                            //   items: homeVM.gender,
                            //   selectedItem: homeVM.selectedGender,
                            //   onChanged: (selectedValue) {
                            //     homeVM.updateGender(selectedValue!); // Use a method to update and notify listeners
                            //   },
                            // ):
                            // NormalTextField(
                            //   height: 50,
                            //   controller: homeVM.genderController,
                            //   hintText: AppLocalizations.of(context).translate('gender'),
                            //   inputType: TextInputType.text,
                            //   isEnabled: false,
                            //   disableColor: MyColors.primaryLight,
                            //   disableTextColor: MyColors.black,
                            // ),
                            // SB.h(15),
                            // TextSubHeading(text: AppLocalizations.of(context).translate('nationality'),fontSize: 13,fontWeight: FontWeight.w400,color: MyColors.blackLight,),
                            // SB.h(10),
                            // (homeVM.selectedNationality == "" || homeVM.selectedNationality == AppLocalizations.of(context).translate('selectNationality')) ?
                            // CustomSpinner(
                            //   items: homeVM.nationalities,
                            //   selectedItem: homeVM.selectedNationality,
                            //   onChanged: (selectedValue) {
                            //     homeVM.updateNationalities(selectedValue!);
                            //   },
                            //   // isEnabled: widget.timelinesViewModel.isChequeAndRemittanceEnable,
                            // ):
                            // NormalTextField(
                            //   height: 50,
                            //   controller: homeVM.nationalityController,
                            //   hintText: AppLocalizations.of(context).translate('nationality'),
                            //   inputType: TextInputType.text,
                            //   isEnabled: false,
                            //   disableColor: MyColors.primaryLight,
                            //   disableTextColor: MyColors.black,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
        // bottomNavigationBar: Column(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Consumer<HomeViewModel>(
        //       builder: (mContext, homeVM, child) {
        //         return
        //           // homeVM.getGenderValue.isNotEmpty &&
        //           //   homeVM.getNationalValue.isNotEmpty ?
        //           //   Container():
        //         Padding(
        //           padding: const EdgeInsets.symmetric(horizontal: 20.0),
        //           child: PrimaryButton(
        //             bgColor: MyColors.orange,
        //             buttonText: AppLocalizations.of(context).translate('update'),
        //             fontWeight: FontWeight.w700,
        //             textSize: 16,
        //             isLoading: homeVM.isLoading,
        //             // isDisabled: homeVM.selectedGender.isEmpty ||
        //             //     homeVM.selectedNationality.isEmpty ||
        //             //     (homeVM.selectedGender == AppLocalizations.of(context).translate('selectGender') &&
        //             //         homeVM.selectedNationality == AppLocalizations.of(context).translate('selectNationality')),
        //             onPressed: () {
        //               if (homeVM.selectedGender.isEmpty) {
        //                 SnackbarManager().showTopSnack(
        //                   context,
        //                   AppLocalizations.of(context).translate('pleaseSelectGender'),
        //                 );
        //               } else if (homeVM.selectedNationality.isEmpty) {
        //                 SnackbarManager().showTopSnack(
        //                   context,
        //                   AppLocalizations.of(context).translate('pleaseSelectNationality'),
        //                 );
        //               } else {
        //                 if(homeVM.selectedGender == AppLocalizations.of(context).translate('selectGender')){
        //                   homeVM.selectedGender = "";
        //                 }
        //                 if(homeVM.selectedNationality == AppLocalizations.of(context).translate('selectNationality')){
        //                   homeVM.selectedNationality = "";
        //                 }
        //                 homeVM.updateProfile(context);
        //               }
        //             },
        //           ),
        //         );
        //       },
        //     ),
        //     SB.h(10),
        //     const NetworkStatus(),
        //   ],
        // ),
      ),
    );
  }
}
