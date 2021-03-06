import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meetup_xpeho/image_provider.dart';
import 'package:provider/provider.dart';

class TeamMember {
  String name;
  String firstName;
  String mission;

  TeamMember({this.name, this.firstName, this.mission});
}

class TeamProvider with ChangeNotifier {
  List<String> _missions = List();
  List<TeamMember> _team = List();

  TeamProvider() {
    _missions.add('Tech lead');
    _missions.add('Dev');
    _missions.add('PO');
    _missions.add('Scrum master');
    fetchTeamMembers();
  }

  void fetchTeamMembers() async {
    _team.clear();
    _team.add(
        TeamMember(name: "FLEURY", firstName: "Piotr", mission: "Tech lead"));
    _team.add(TeamMember(
      name: "MAKUSA",
      firstName: "Nayden",
      mission: "Dev",
    ));
    notifyListeners();
  }

  List<TeamMember> get team => _team;

  TeamMember member(index) => team[index];

  List<String> get missions => _missions;

  void addMember(TeamMember member) {
    _team.add(member);
    notifyListeners();
  }

  void delete(TeamMember member) {
    _team.remove(member);
    notifyListeners();
  }
}

class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamProvider(),
      child: Consumer<TeamProvider>(
        builder: (context, teamProvider, _) {
          return SafeArea(
            child: Scaffold(
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      child: Container(),
                      decoration: BoxDecoration(
                          image: DecorationImage(image: logo().image)),
                    ),
                    ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text("Refresh"),
                      onTap: () {
                        Navigator.of(context).pop();
                        _refresh(teamProvider);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.person_add),
                      title: Text("Add member"),
                      onTap: () {
                        Navigator.of(context).pop();
                        _addPressed(teamProvider);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: Text("About"),
                      onTap: () {
                        Navigator.of(context).pop();
                        showAboutDialog(context: context);
                      },
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () => _addPressed(teamProvider),
              ),
              body: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    elevation: 8.0,
                    floating: true,
                    pinned: true,
                    snap: true,
                    flexibleSpace: Stack(children: <Widget>[
                      Positioned.fill(
                        child: banner(),
                      ),
                    ]),
                    // Make the initial height of the SliverAppBar larger than normal.
                    expandedHeight: 160,
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () => _refresh(teamProvider),
                      ),
                    ],
                  ),
                  buildMemberList(teamProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _refresh(TeamProvider teamProvider) => teamProvider.fetchTeamMembers();

  Widget buildMemberList(TeamProvider teamProvider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          TeamMember member = teamProvider.member(index);
          return Dismissible(
            confirmDismiss: (direction) => _confirmDismiss(context),
            key: GlobalKey(),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                _deleteMember(teamProvider, member);
              }
            },
            background: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      trailing: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.red,
                  ),
                )
              ],
            ),
            child: ListTile(
              title: Text("${member.name} ${member.firstName}"),
              subtitle: Text(member.mission),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _editMember(teamProvider, member),
            ),
          );
        },
        // Builds 1000 ListTiles
        childCount: teamProvider.team.length,
      ),
    );
  }

  Future<bool> _confirmDismiss(BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Confirm"),
              content: Text("Supprimer le membre de l'équipe ?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Oui"),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                FlatButton(
                  child: Text("Non"),
                  onPressed: () => Navigator.of(context).pop(false),
                )
              ],
            ));
  }

  void _addPressed(TeamProvider teamProvider) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            height: 200,
            child: ListView.builder(
              itemCount: teamProvider.missions.length,
              itemBuilder: (_, index) {
                String mission = teamProvider.missions[index];
                return FlatButton(
                  child: Text(mission),
                  onPressed: () {
                    Navigator.of(context).pop();
                    addMember(teamProvider, mission);
                  },
                );
              },
            ),
          );
        });
  }

  void addMember(TeamProvider teamProvider, String _mission) async {
    final member = await Navigator.of(context).pushNamed(
      '/editMember',
      arguments: TeamMember(mission: _mission),
    );
    if (member != null) {
      teamProvider.addMember(member);
    }
  }

  void _editMember(TeamProvider teamProvider, TeamMember _member) async {
    Navigator.of(context).pushNamed(
      '/editMember',
      arguments: _member,
    );
  }

  void _deleteMember(TeamProvider teamProvider, TeamMember _member) async {
    teamProvider.delete(_member);
  }
}
