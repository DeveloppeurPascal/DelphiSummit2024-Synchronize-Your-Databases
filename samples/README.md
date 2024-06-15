# Synchronize your databases - Delphi Summit 2024

I had too many things to say and show during my presentation at the [Delphi Summit 2024](https://delphisummit.com/) conference. Here are the sample projects you have't seen working live on stage.

* [Contacts](Contacts/) is a simple program with only one table in its database with logical deletions.
![../DB/contacts.png]()

* [TODO List](TODOList/) is the same but the detelions are physical.
![../DB/todos.png]()

* [Q & A](QandA/) was done to allow attendees to send questions to speakers and obtain answers to their questions without seeing questions of other attendees. 2 tables with a relation between them and a non mirroring tables synchronisations.

* [Simple Notes](SimpleNotes/) is not so simple which has a topics tree ("folder" table) where we put one or more notes ("item" table). 2 tables samples with foreign keys and recursion.
![../DB/simplenotes.png]()

They all use a local SQLite databse. The synchronisation process is done by the [Table Data Sync client library for Delphi](https://github.com/DeveloppeurPascal/TableDataSync4Delphi).

We have only one [WebBroker synchronization server](DBServer/) for those samples. It has the same databases structures by using client's DB data modules.
