import 'package:flutter/material.dart';
import 'package:ghii/Services/api_service.dart';
import 'package:ghii/Services/db_helper.dart';
import 'package:ghii/models/repository.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Repository>> _repositories;
  final RepoService _repoService = RepoService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoadingFromAPI = true;
  bool _showStoredData = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingFromAPI = true;
    });

    try {
      _repositories = _repoService.fetchRepository();

      // Once API data is loaded, save to local storage
      _repositories.then((repos) async {
        for (var repo in repos) {
          await _databaseHelper.insertData(repo);
        }
        setState(() {
          _isLoadingFromAPI = false;
        });
      });
    } catch (e) {
      print('Error loading from API: $e');
      setState(() {
        _isLoadingFromAPI = false;
        _showStoredData = true;
      });
    }
  }

  Future<List<Repository>> _getStoredData() async {
    return await _databaseHelper.getAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GHII Repository'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: Icon(_showStoredData ? Icons.cloud : Icons.storage),
            onPressed: () {
              setState(() {
                _showStoredData = !_showStoredData;
              });
            },
            tooltip: _showStoredData ? 'Show API Data' : 'Show Stored Data',
          ),
        ],
      ),
      body: _showStoredData
          ? FutureBuilder<List<Repository>>(
        future: _getStoredData(),
        builder: _buildRepositoryList,
      )
          : FutureBuilder<List<Repository>>(
        future: _repositories,
        builder: _buildRepositoryList,
      ),
    );
  }

  Widget _buildRepositoryList(
      BuildContext context, AsyncSnapshot<List<Repository>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('No data found'));
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else {
      List<Repository> repositories = snapshot.data!;

      return ListView.builder(
        itemCount: repositories.length,
        itemBuilder: (context, index) {
          final repo = repositories[index];
          return ListTile(
            title: Text(repo.fullName),
            subtitle: Text(repo.description ?? 'No description'),
            leading: repo.avatar_url.isNotEmpty
                ? Image.network(
              repo.avatar_url,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.account_circle, size: 40);
              },
            )
                : Icon(Icons.account_circle, size: 40),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _databaseHelper.deleteData(repo.id);
                setState(() {
                  repositories.removeAt(index);
                });
              },
            ),
          );
        },
      );
    }
  }
}