import 'dart:core';
class Repository{
  String? name;
  String? description;
  int? id;
  Repository({this.id,this.name,this.description});
  factory Repository.fromJson(Map<String,dynamic> json){
    return Repository(
      id: json['id']??0,
      name: json['name']?? "null",
      description: json['description']?? "null",
    );
  }
}

class RepoList{
  List<Repository> repos;
  RepoList({required this.repos});
  factory RepoList.fromJson(List<dynamic>json){
    late List<Repository> repos;

    repos=json.map((r)=>Repository.fromJson(r)).toList();
    return RepoList(repos: repos);
  }
}

class Commit{
  String? sha;
  String? author;
  String? message;
  Commit({this.sha,this.author,this.message});
  factory Commit.fromJson(List<dynamic>json){
    String? sha=json[0]['sha']??'null';
    CommitHead? commit= json[0]['commit'] != null ? CommitHead.fromJson(json[0]['commit']) : null;
    String author="null",message="null";
    author=commit!.committer!.name??"null";
    message=commit.message??"null";
    return Commit(sha: sha,author: author,message:message);
  }
}

class CommitHead {
  Author? committer;
  String? message;
  CommitHead(
      {
        this.committer,
        this.message,
});

 factory CommitHead.fromJson(Map<String, dynamic> json) {
    Author? committer = json['committer'] != null
        ? Author.fromJson(json['committer'])
        : null;
    String? message = json['message'];
    return CommitHead(committer:committer,message:message);
  }


}

class Author {
  String? name;
  String? email;
  String? date;

  Author({this.name, this.email, this.date});

  Author.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    date = json['date'];
  }

}