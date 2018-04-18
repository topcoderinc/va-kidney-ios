The list of fixed issues:

https://github.com/topcoderinc/va-kidney-ios/issues/14
It’s related to https://github.com/topcoderinc/va-kidney-ios/issues/26
Food Suggestions are implemented.

https://github.com/topcoderinc/va-kidney-ios/issues/15
This was already implemented. For some drug sets there are no information in FDA database, so to verify you need to use the drugs that have interaction info (see an example in previous challenge video https://youtu.be/rUsXsVh8r7Y?t=43s )

https://github.com/topcoderinc/va-kidney-ios/issues/16
>1. Adding a new meal or drug and then go back and come again won't show the second meal/drug added
>2. If the user added multiple meal and drug and go back to the Food intake screen will display the first item added below the image
= Now fixed. When user tapped “Back” button the data was not saved. It’s OK, but the app should ask user to confirm that. Now the app asks to confirm and warns that it will not be saved. The data is saved only when user tap “Save …” button.

>3. After taking a photo from the camera and tap on 'Add New meal' button will display validation message ending with \
= Now the message is correct - “Please add at least one meal/drug”

>4. 'Add New Meal' button text hides when user tap on it without filling data
= Fixed

>5. App crash when user select unit as 'L' and save the data
= In existing app a few conditions should be met to catch the crash. It was due to items that estimated using “gram” unit were saved with “liter” units. To verify the fix, first try to reproduce it with the initial code:
1) Launch the app and edit profile by changing “Disease Category” (it’s required to setup goals automatically; initial set of goals is incorrect - this is another issue and is also fixed);
2) Add Food with Food Item named “water”. Save.
If all conditions are met, then NDB service will return items for “water” and the app will identify them as related to “Fluid Intake” goal. The taken items are saved in HK only if they are identified to be related to one of the goals. When they are saved, the app crashes.
Now try the same in the updated app.

6. If `water` is saved as food item, then the items defined by NDB service include Vitamin B6. There was issue that Vitamin B6 was not saved. Now it’s. Try to save some `water` (make sure you have Water Intake goal defined by the disease) and verify the last messages in Xcode console after a few seconds. They should be as follows: 
addItem: Saved 0.25 g  (2018-03-28 12:30:36 +0300 - 2018-03-28 12:30:36 +0300) of HKQuantityTypeIdentifierDietaryNiacin
addItem: Saved 0.03333 g  (2018-03-28 12:30:38 +0300 - 2018-03-28 12:30:38 +0300) of HKQuantityTypeIdentifierDietaryVitaminB6
addItem: Saved 1 L  (2018-03-28 12:30:41 +0300 - 2018-03-28 12:30:41 +0300) of HKQuantityTypeIdentifierDietaryWater
7. In relation to previous issue. Water food item was not saved as `DietaryWater` in HealthKit (the only item presented in HealthKit that represents water). Now it’s saved along with its ingredients  (Vitamin B6, Niacin) defined by NDB service.

8. There was one more issue - Per-month data was requested incorrectly - the data was requested for the reference date that represents a middle of the month (current day). After the fix the periods start at 12:00AM in current timezone (21:00:00 +0000 in my timezone). Compare the two outputs of the requested data (before and after the fix in `HealthKitUtil.getPerMonthStatistics` method):
// Before
statistics: <<HKStatistics: 0x6080002e2b80> Statistics on HKQuantityTypeIdentifierDietaryBiotin (2018-01-29 08:17:59 +0000 - 2018-02-28 08:17:59 +0000) over sources ((null))>
statistics: <<HKStatistics: 0x6080002e2b80> Statistics on HKQuantityTypeIdentifierDietaryBiotin (2018-02-28 08:17:59 +0000 - 2018-03-29 08:17:59 +0000) over sources ((null))>
statistics: <<HKStatistics: 0x6000000f7980> Statistics on HKQuantityTypeIdentifierDietaryBiotin (2018-03-29 08:17:59 +0000 - 2018-04-29 08:17:59 +0000) over sources ((null))>

// After
statistics: <<HKStatistics: 0x6040002e0900> Statistics on HKQuantityTypeIdentifierDietaryBiotin (2017-12-31 21:00:00 +0000 - 2018-01-31 21:00:00 +0000) over sources ((null))>
statistics: <<HKStatistics: 0x6040002e0900> Statistics on HKQuantityTypeIdentifierDietaryBiotin (2018-01-31 21:00:00 +0000 - 2018-02-28 21:00:00 +0000) over sources ((null))>
statistics: <<HKStatistics: 0x60c0000ff400> Statistics on HKQuantityTypeIdentifierDietaryBiotin (2018-02-28 21:00:00 +0000 - 2018-03-31 21:00:00 +0000) over sources (<HKSource:0x60c000274940 "VAKidneyNutrition" (com.topcoder.VAKidneyNutrition)>)>

In some cases (at a specific timezones and time) the issue resulted in missing just added data.
To verify this try the following with initial code base and then in the updated app:
1. Remove the app and relaunch
2. Open any chart with item that is supported by HK, e.g. “Water” chart.
3. Add value and check if chart appear with a single value. 
Expected: The chart appear and shows one point (not line) that represents a single added value.
Actual (in initial code): No chart is shown. It was in GMT-3 timezone at 8:18AM. If you cannot reproduce it with initial code in you timezone, then try the given timezone and local time settings (GMT-3 timezone; time: 8:18AM).

https://github.com/topcoderinc/va-kidney-ios/issues/18
>'Alchohol' Lab values is not working, can't add a record using the '+' option
“alcohol”, “meat” and “vegetables” are custom items that are NOT supported by HealthKit (Health app). That is why they were not saved.
Now it’s fixed. Try to save all three custom times. They are defined in new `enum QuantityTypeCustom`.

>Can't see any data related to 'Goal' only entered values are displayed on the chart. For example, if we set a Goal for Water intake and Add an actual value from (+) add button won't render the chart

No goal lines are shown in charts for items that are related to existing goals. Now fixed. Three conditions should be met to show goal lines in charts:
1) There should be some data for the item (lab value).
2) Related goal should have exactly the same related quantity ID (new field in Goal.swift `relatedQuantityId`).
3) Goal should have `min` or `max` or both values (see `allGoals.json`. Goals fields are nested from corresponding `style` and can be overridden). For example, all goals with `style==Pills` have min and max by default.

There are issue here that only goals of `goalType==.orderedSame` had goal lines (this was because only such type of goals have two goal lines - min and max). Now this condition is removed and all goals with the conditions mentioned above have one or two goal lines.

https://github.com/topcoderinc/va-kidney-ios/issues/20
- Goal lines are shown.
- Custom types are now saved correctly, e.g. alcohol, meat, vegetables.

https://github.com/topcoderinc/va-kidney-ios/issues/23
According to the discussion we need to implement the following:
1) Save custom items (lab values) locally because HK does not support them.
2) If used denied write access for some HK items, then we also save them locally.
3) If HK service returns empty set for charts, then try read local data. This covers the case when user denied read access for the item type and we save data locally (see discussion - it’s not possible to check if user allowed/disabled read access - HK just either returns some data or not).

All three are implemented as QuantitySampleService protocol and classes that implements it. The logic for 1-3 are implemented in QuantitySampleStorage.swift. See docs/QuantitySampleStorage.png for class diagram. Local data storage for custom and denied items is implemented in LocalQuantitySampleService.swift.

https://github.com/topcoderinc/va-kidney-ios/issues/24
The requirements are:
- Show caption for goals. Caption - is red circle with “Goal” label that is shown in legend if goal lines are shown (see video dodo).
- Always show start and end Oy values (even if goal lines are shown with their own values).

Caption is shown as “Goal” if one goal line is shown and “Goals” if more. Oy values are always shown (the values are calculated by the Chart library automatically). Goal values are also shown and marked with either “minimum” or “maximum” label, e.g. “200 (minimum)”.

https://github.com/topcoderinc/va-kidney-ios/issues/25
The requirements is to provide a set of goals to add that correspond to currently selected Disease Category and Dialysis in profile.
The solution is to update “Add Goal” form as follows:
- goal category tab bar on the top is replaced with goal selector (`category` field is an atavism from the first prototype; now only goal title is needed);
- use patterns of the goals from “allGoals.json” to fulfill the top tab bar in “Add Goal”.

Also another issue was found - when user login for the first time after the prototype is installed the list of goals is incorrect. Also those goals are not correctly setup and some of the do not correspond to items, e.g. if you will add `water` in Charts, then you will not see goal lines in the chart (in the app compiled from initial code). Now the issue is fixed. After login a set of goals correspond to the Disease Category specified by default and are correctly setup (In initial code you had to tweak the field in Profile to regenerate the correct goals). dodo
`goalCategories.json` and `goals.json` are removed because now all goals are generated based on `allGoals.json` only.

https://github.com/topcoderinc/va-kidney-ios/issues/26
The requirements are to improve Food suggestions with the following:
- Generate Food suggestions with low content of given ingredient.
- Generate “Unsafe Food” with high content of given ingredients.

The solutions for both is to find the corresponding food by sending a request to NDB and ordering food by nutrition content per measure (like the following list https://ndb.nal.usda.gov/ndb/nutrients/report/nutrientsfrm?max=25&offset=0&totCount=0&nutrient1=203&nutrient2=&nutrient3=&subset=0&sort=c&measureby=g)

The resulted report isn’t very attractive because the food titles are very formal. Although, it’s very accurate (in terms of what food is best and what is worse).
I would recommend to provide a pair of recommendations for each nutrient that can be added as static texts into the app and used instead of requesting NDB.
This can be done by implementing alternative RecommendationGenerator.

Also the implementation still needs improvements because it’s not very clear how the algorithms should work. The logic should be implemented after algorithms are clearly defined.

- dodo check if goal exceeds the maximum per day (currently it just generates a report for first nutrient)

https://github.com/topcoderinc/va-kidney-ios/issues/27
Fixed. However, the data is automatically synchronized every time the screen is opened. So, the label will always be “Synchronized just now” first. Then it will be always up to date. You can verify that by waiting for a few seconds/minutes while this screen is opened.

https://github.com/topcoderinc/va-kidney-ios/issues/28
Fixed with gray color for highlighted state.

https://github.com/topcoderinc/va-kidney-ios/issues/29
The issue fixed. When “Add new meal” tapped without filling the form it still rendered correctly.
However, another issue here - when user tap and hold the button the button title disappears. Now it’s fixed - the title become gray.
Try highlighted state for the button in all submissions.

https://github.com/topcoderinc/va-kidney-ios/issues/30
Fixed

https://github.com/topcoderinc/va-kidney-ios/issues/31
Button title changed to "Add New Meal/Drug" for add form and "Save Meal/Drug" for edit form.

https://github.com/topcoderinc/va-kidney-ios/issues/32
The edit form title changed to "Edit Meal/Drug" and add form title to “Add New Meal/Drug" (the second was changed from “”Add New Meal” - another issue; check it in all submissions).

https://github.com/topcoderinc/va-kidney-ios/issues/33
Implemented - the items with data have bold font

https://github.com/topcoderinc/va-kidney-ios/issues/34
Date field is added to the form.

https://github.com/topcoderinc/va-kidney-ios/issues/35
Fixed. Min 45lbs (20kg+), Max 800lbs.

https://github.com/topcoderinc/va-kidney-ios/issues/36
Fixed. Min value is 3ft.

https://github.com/topcoderinc/va-kidney-ios/issues/37
Fixed. Min age can be 16 years (defined in ProfileViewController.MIN_AGE)
Also the maximum date issue is fixed in “Add Meal” form. User was allowed to select date in future. Now fixed. He cannot save meal eaten in future.

https://github.com/topcoderinc/va-kidney-ios/issues/38
Fixed.

https://github.com/topcoderinc/va-kidney-ios/issues/39
Fixed in “Add Meal/Drug” (opened from “Add New Meal/Drug”) and “Add Item” (opened from Charts) forms.

https://github.com/topcoderinc/va-kidney-ios/issues/40
Fixed in DailyWorkoutViewController.syncFromHK(). The callbacks in HealthKitUtil are always invoked even if read access dined or any other error occurred.

https://github.com/topcoderinc/va-kidney-ios/issues/41
(note #1)Now ServiceApi protocol methods are used instead of direct access to CachingServiceApi
A separate protocol is added to access Recommendations database - RecommendationServiceApi.
`getProfile()` method was part of ServiceApi protocol from very beginning.
You can verify that all services are now used through protocols by searching `CachingServiceApi.shared.` (don’t forget to add dot at the end) - there are no usages. If you will search `CachingServiceApi.shared` (without dot at the end), then you will see that all variables have protocol type (either ServiceApi or RecommendationServiceApi).
(notes #2 and #3)Instead of creating new class I added `extension CachingServiceApi` as recommended in https://github.com/topcoderinc/va-kidney-ios/issues/42

https://github.com/topcoderinc/va-kidney-ios/issues/42
- FoodDetailsServiceApi and DrugDetailsServiceApi protocols added;
- FoodUtils uses all services through protocols (ServiceApi, RecommendationServiceApi, FoodDetailsServiceApi, DrugDetailsServiceApi).

https://github.com/topcoderinc/va-kidney-ios/issues/43
Class renamed. Type alias removed.

https://github.com/topcoderinc/va-kidney-ios/issues/44
- “Cache-Control” HTTP header added in RESTApi.swift;
- CachingNDBServiceApi and CachingFDAServiceApi are implemented and used.

A few more issues are fixed:
- The goals were updated incorrectly after saving food. The units used in goals (e.g. glass) do not match to units of the samples (e.g. liter). As a result after adding 1L of water the goal was increased by 1 glass. Now it fixed. In the mentioned example it will be updated with 5 glasses (`oneUnitValue` field for this goal is 0.2L).
- The goals were not updated after adding nutrients in Charts screen. Now fixed.

