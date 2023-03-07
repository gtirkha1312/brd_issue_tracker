import 'package:brd_issue_tracker/dashboard/provider/issues_assigned_to_me_provider.dart';
import 'package:brd_issue_tracker/dashboard/provider/sorted_list_provider.dart';
import 'package:brd_issue_tracker/dashboard/widgets/dialogs/assign_to_dialog.dart';
import 'package:brd_issue_tracker/dashboard/widgets/dialogs/edit_dialog.dart';
import 'package:brd_issue_tracker/dashboard/widgets/dialogs/show_description_dialog.dart';
import 'package:brd_issue_tracker/login/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../shared/util.dart';
import '../../../shared/util_widgets.dart';
import '../../../static_data.dart';

class AssignedIssueHome extends StatefulWidget {
  const AssignedIssueHome(
      {super.key, required this.authToken, required this.safesize});
  final String authToken;
  final Size safesize;

  @override
  State<AssignedIssueHome> createState() => _AssignedIssueHomeState();
}

class _AssignedIssueHomeState extends State<AssignedIssueHome> {
  double myPadding = 16;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!Provider.of<IssuesAssignedToMeProvider>(context, listen: false)
          .isLoading) {
        Provider.of<SortedListProvider>(context, listen: false).setSortedList(
            Provider.of<IssuesAssignedToMeProvider>(context, listen: false)
                .myIssuesList);
      }
    });
  }

  ValueNotifier<bool> isExpanded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    IssuesAssignedToMeProvider assignedToMeProvider =
        Provider.of<IssuesAssignedToMeProvider>(context);
    SortedListProvider sortedListProvider =
        Provider.of<SortedListProvider>(context);
    String myId =
        Provider.of<AuthProvider>(context, listen: false).loggedInUser!.id;

    return Container(
      height: widget.safesize.height * .90,
      width: widget.safesize.width * .90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Stack(
        children: [
          Container(
            child: assignedToMeProvider.isLoading
                ? const Center(
                    child: SpinKitFadingCube(color: Colors.deepOrange))
                : assignedToMeProvider.isError
                    ? const Center(child: Text("Error Occured"))
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.all(myPadding),
                            color: const Color.fromARGB(255, 244, 246, 247),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        sortedListProvider
                                            .sortedList[index].title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                    hSizedBoxMedium(),
                                    PriorityBox(
                                      value: sortedListProvider
                                          .sortedList[index].priority,
                                    ),
                                  ],
                                ),
                                vSizedBoxSmall(),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: widget.safesize.width * .18,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: "Created By: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text: sortedListProvider
                                                      .sortedList[index]
                                                      .createdBy,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: "Created : ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text: getIssueDayString(
                                                      sortedListProvider
                                                          .sortedList[index]
                                                          .createdAt),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: "Last Updated : ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: getIssueDayString(
                                                    sortedListProvider
                                                        .sortedList[index]
                                                        .updatedAt),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: "Status : ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: sortedListProvider
                                                    .sortedList[index].status,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    CustomViewIssueButton(
                                      issue:
                                          sortedListProvider.sortedList[index],
                                    ),
                                    CustomUpdateStatusButton(
                                      issue:
                                          sortedListProvider.sortedList[index],
                                    ),
                                    if (sortedListProvider
                                            .sortedList[index].createdById ==
                                        myId)
                                      CustomEditButton(
                                        issue: sortedListProvider
                                            .sortedList[index],
                                      ),
                                    if (sortedListProvider
                                            .sortedList[index].status !=
                                        COMPLETED)
                                      CustomAssignToOtherButton(
                                        issue: sortedListProvider
                                            .sortedList[index],
                                      ),
                                    SizedBox(width: widget.safesize.width * .03)
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemCount: sortedListProvider.sortedList.length),
          ),
          ValueListenableBuilder(
            valueListenable: isExpanded,
            builder: (context, value, child) {
              SortedListProvider provider =
                  Provider.of<SortedListProvider>(context, listen: false);
              return Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      tooltip: "sort",
                      onPressed: () {
                        isExpanded.value = !value;
                      },
                      child: Icon(Icons.sort),
                    ),
                    if (value) const SizedBox(height: 10),
                    if (value)
                      FloatingActionButton(
                        tooltip: "Sort By Date",
                        onPressed: () {
                          provider.sortIssuesByCreationDate();
                        },
                        child: Icon(Icons.calendar_month),
                      ),
                    if (value) const SizedBox(height: 10),
                    if (value)
                      FloatingActionButton(
                        tooltip: "Sort By Priority",
                        onPressed: () {
                          provider.sortIssuesByPriority();
                        },
                        child: Icon(Icons.low_priority),
                      ),
                    if (value) const SizedBox(height: 10),
                    if (value)
                      FloatingActionButton(
                        tooltip: "Sort By Updated",
                        onPressed: () {
                          provider.sortIssuesByUpdateDate();
                        },
                        child: Icon(Icons.calendar_view_day_rounded),
                      ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
