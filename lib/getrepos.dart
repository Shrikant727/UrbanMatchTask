import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/github_repositories.dart';
import 'package:http/http.dart' as http;


Future<List<Repository>> getReposList(user) async{
  final uri = Uri.parse('https://api.github.com/users/'+user+'/repos');
  String username = 'test';
  String password = '123£';
  String basicAuth ='Basic ' + base64.encode(utf8.encode('$username:$password'));
  final response= await http.get(uri, headers: <String, String>{'authorization': basicAuth});
  if(response.statusCode==200){
    RepoList r=RepoList.fromJson(json.decode(response.body));
    List<Repository>rd=<Repository>[];
    for(int i=0;i<r.repos.length;i++){
      rd.add(Repository(id: r.repos[i].id,name: r.repos[i].name,
          description:r.repos[i].description));
    }
    return rd;
  }
  else{
    throw Exception("Error Loading Data");
  }
}
Future<List<Commit>> getCommit(List<Repository> repos,String user) async {
  List<Commit>comlist=[];
  Map<String,String>m={"per_page":'1'};
  String username = 'test';
  String password = '123£';
  String basicAuth ='Basic ' + base64.encode(utf8.encode('$username:$password'));
  String baseurl='https://api.github.com/repos/'+user+'/';
  for(int i=0;i<repos.length;i++){
    final uri=Uri.parse('$baseurl${repos[i].name!}/commits').replace(queryParameters:m);
    final response= await http.get(uri, headers: <String, String>{'authorization': basicAuth});
    if(response.statusCode==200){
      Commit c=Commit.fromJson(json.decode(response.body));
      comlist.add(c);
    }
    else{
      throw Exception('Error while fetching data');
    }
  }
  return comlist;
}
class GetRepos extends StatefulWidget {
  const GetRepos({Key? key}) : super(key: key);
  @override
  State<GetRepos> createState() => _GetReposState();
}

class _GetReposState extends State<GetRepos> {
  late Future<RepoList> reposlist;
  late Future<List<Repository>>repos;
  late Future<List<Commit>>commits;
  String user='Shrikant727';
  @override
  void initState() {
    super.initState();
    repos=getReposList(user);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: Colors.green,
          elevation:7,
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/github_logo.png'),
            ),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('UrbanMatch Task ',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                ),
              ),
              Text('By Shrikant Bhadgaonkar',
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                ),)
            ],
          ),

        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FutureBuilder<List<Repository>>(
            future:repos,
            builder: (context,snapshot){
              if(snapshot.hasData){
                List<Repository>?newdata=snapshot.data;
                commits=getCommit(newdata!,user);
                return ListView.builder(itemCount:newdata.length, itemBuilder:(context,index){
                  return Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child:Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(newdata[index].name!,
                              style: GoogleFonts.roboto(fontWeight: FontWeight.bold,fontSize: 18),
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Text('Description: ',style:GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                                Flexible(
                                  child: Text(newdata[index].description!,
                                    style: GoogleFonts.roboto(),
                                    overflow: TextOverflow.ellipsis,),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('last commit: ',style:GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                                Flexible(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                      color: Color.fromRGBO(221, 221, 222, 1),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FutureBuilder(
                                        future: commits,
                                        builder: (context,snapshot){
                                          if(snapshot.hasData){
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("Committer: ",style:GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                                                    Text(snapshot.data![index].author!),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text("Message: ",style:GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                                                    Flexible(child: Text(snapshot.data![index].message!)),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }
                                          else if(snapshot.hasError){
                                            return Text(snapshot.error.toString());
                                          }
                                          return Container(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator());
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),

                          ],
                        ),
                      )
                  );
                });
              }
              else if(snapshot.hasError){
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              return const Center(child: CircularProgressIndicator(),);
            },
          )
      ),
    );
  }

}
