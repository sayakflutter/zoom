import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teacher_live_class/createmeetingui.dart';
import 'package:teacher_live_class/getx.dart';
import 'package:teacher_live_class/model/meetingdetails.dart';
import 'package:teacher_live_class/vc_controller.dart';
import 'package:teacher_live_class/vc_methods.dart';
import 'package:teacher_live_class/vc_screen.dart';

class DashboardUI extends StatefulWidget {
  final List<String> args;

  const DashboardUI(this.args);

  @override
  _DashboardUIState createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI>
    with SingleTickerProviderStateMixin {
  final Getx getx = Get.put(Getx());
  late TabController _tabController;
  String pageTitle = 'Today Meetings';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print(widget.args);
      if (widget.args[0].isNotEmpty && widget.args[0].length >= 20) {
        getx.initiallizeSharePreferrance(widget.args[0]);
      }
      getx.getMeetingList();
    });
    _tabController = TabController(length: 3, vsync: this);

    // Listen to tab changes
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            pageTitle = 'Today Meetings';
            break;
          case 1:
            pageTitle = 'Upcoming Meetings';
            break;
          case 2:
            pageTitle = 'Past Meetings';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideNavigation(),
      appBar: _buildTopBar(),
      body: Column(
        children: [
          _buildHeaderRow(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMeetingList(getx.todaymeeting), // Today's meetings
                _buildMeetingList(getx.upcomingmeeting), // Upcoming meetings
                _buildMeetingList(getx.pastmeeting), // Past meetings
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Side Navigation Bar
  Widget _buildSideNavigation() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.args[0]),
          ),
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Dashboard'),
          ),
          ListTile(
            leading: Icon(Icons.video_call),
            title: Text('Meetings'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
      ),
    );
  }

  Color scaffoldColor = const Color(0xff1B1A1D);
  // Top Bar
  PreferredSizeWidget _buildTopBar() {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: scaffoldColor,
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: constraints.maxWidth * 0.6,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Header Row with "Live Video List" title and "Create Live" button
  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              pageTitle,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          MaterialButton(
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(6)),
            padding: EdgeInsets.all(15),
            color: const Color.fromARGB(255, 11, 137, 240),
            onPressed: () {
              Get.to(() => CreateMeeting());
            },
            child: Text(
              "Create Meeting",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Tab Bar
  Widget _buildTabBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color.fromARGB(255, 0, 0, 0),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color.fromARGB(255, 3, 6, 223),
        isScrollable: true,
        tabs: [
          Tab(text: 'Today Meetings'),
          Tab(text: 'Upcoming Meetings'),
          Tab(text: 'Past Meetings'),
        ],
      ),
    );
  }

  // Meeting List based on Tab
  Widget _buildMeetingList(RxList<MeetingDeatils> meetings) {
    return _buildGridView(meetings);
  }

  // Grid/List of Cards
  Widget _buildGridView(RxList<MeetingDeatils> meetings) {
    return Obx(
      () => meetings.isNotEmpty
          ? LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                double childAspectRatio;

                if (constraints.maxWidth >= 1200) {
                  crossAxisCount = 4;
                  childAspectRatio =
                      1.5; // Adjust aspect ratio for larger screens
                } else if (constraints.maxWidth >= 800) {
                  crossAxisCount = 3;
                  childAspectRatio =
                      1.4; // Adjust aspect ratio for medium screens
                } else if (constraints.maxWidth >= 600) {
                  crossAxisCount = 2;
                  childAspectRatio =
                      1.2; // Adjust aspect ratio for smaller screens
                } else {
                  crossAxisCount = 1;
                  childAspectRatio =
                      1.0; // Adjust aspect ratio for very small screens
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    return _buildCard(meetings[index], constraints);
                  },
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // Card Widget
  Widget _buildCard(MeetingDeatils meeting, BoxConstraints constraints) {
    print(meeting.sessionId);
    final controller = Get.put(VcController(), permanent: true);

    final title = meeting.videoName;
    final package = meeting.packageName;

    final topic = meeting.topicName;
    final duration = '${meeting.videoDuration} minutes';
    final schedule = meeting.scheduledOn;

    double fontSize = constraints.maxWidth > 800 ? 18 : 16;
    EdgeInsets padding = constraints.maxWidth > 800
        ? const EdgeInsets.all(12.0)
        : const EdgeInsets.all(8.0);

    return Card(
      color: scaffoldColor,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 8),
            Flexible(
              child: Text(
                'Package: $package',
                style: TextStyle(color: Colors.grey, fontSize: fontSize * 0.9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                'TopicName: $topic',
                style: TextStyle(color: Colors.grey, fontSize: fontSize * 0.9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                'Duration: $duration',
                style: TextStyle(color: Colors.grey, fontSize: fontSize * 0.9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                'Scheduled: $schedule',
                style: TextStyle(color: Colors.grey, fontSize: fontSize * 0.9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: MaterialButton(
                color: const Color.fromARGB(255, 11, 137, 240),
                onPressed: () async {
                  controller.inMeetClient.init(
                    socketUrl: 'wss://wriety.inmeet.ai',
                    projectId: meeting.projectId.toString(),
                    userName: 'Sayak Mishra',
                    userId: meeting.hostUid.toString(),
                    listener: VcEventsAndMethods(vcController: controller),
                  );
                  await controller.inMeetClient
                      .join(sessionId: meeting.sessionId.toString());

                  Get.off(() => MeetingPage(meeting.sessionId,
                      meeting.hostUid.toString(), 'Sayak Mishra'));
                },
                child: Text(
                  'Join',
                  style:
                      TextStyle(color: Colors.white, fontSize: fontSize * 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
