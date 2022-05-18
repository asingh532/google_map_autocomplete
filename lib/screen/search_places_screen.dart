import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_map_autocomplete/screen/map_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SearchPlaceScreen extends StatefulWidget {
  const SearchPlaceScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  late TextEditingController _editingController;
  var uuid = const Uuid();
  String _sessionToken = "";
  List<dynamic> _placesList = [];

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();

    _editingController.addListener(() {
      onValueChanged();
    });
  }

  void onValueChanged() {
    if (_sessionToken.isEmpty) {
      _sessionToken = uuid.v4();
    }
    getSuggestionData(_editingController.text);
  }

  getSuggestionData(input) async {
    var api = "API_KEY";
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$api&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    print("Response = ${response.body}");
    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception("Failed to Load Map Places");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _editingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Search Places"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _editingController,
              decoration: const InputDecoration(
                hintText: "Search Places",
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _placesList.length,
                itemBuilder: (context, index) {
                  var address = _placesList[index]['description'];
                  return ListTile(
                    onTap: () async {
                      await locationFromAddress(address).then((value) {
                        var lat = value.last.latitude;
                        var longi = value.last.longitude;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: ((context) => MapScreen(
                                  latitude: lat,
                                  longitude: longi,
                                  address: address,
                                )),
                          ),
                        );
                      });

                      // Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen());
                    },
                    title: Text(address),
                  );
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}
