import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class SecondPage extends StatefulWidget {
  final currency;
  const SecondPage(this.currency, {Key? key}) : super(key: key);
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<dynamic> _tickers = [];
  bool _isLoading = true;
  bool _sortAscending = false; // variable pour l'ordre croissant
  int _selectedSortType = 0; // variable pour le type de tri sélectionné

  // fonction pour trier les données
  void _sortData(int sortType) {
    setState(() {
      _selectedSortType = sortType;
      switch (sortType) {
        case 0: // tri par ordre alphabétique
          _tickers.sort((a, b) => a['symbol'].compareTo(b['symbol']));
          _sortAscending = true;
          break;
        case 1: // tri par prix
          _tickers.sort((a, b) => a['quotes']['USD']['price']
              .compareTo(b['quotes']['USD']['price']));
          _sortAscending = !_sortAscending;
          break;
        case 2: // tri par change
          _tickers.sort((a, b) => a['quotes']['USD']['percent_change_24h']
              .compareTo(b['quotes']['USD']['percent_change_24h']));
          _sortAscending = !_sortAscending;
          break;
        default:
          break;
      }
    });
  }

  Widget _card(dynamic ticker) {
    final double change =
        ticker['quotes']['USD']['percent_change_24h'].toDouble();
    final bool isPositiveChange = change >= 0;
    return Card(
      color: const Color.fromARGB(255, 53, 13, 118),
      child: ListTile(
        title: Text(ticker['symbol'],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Price: ${ticker['quotes']['USD']['price']} ${widget.currency}',
                style: const TextStyle(color: Colors.white)),
            Row(
              children: [
                Text('Change (24h): ${change.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositiveChange ? Colors.green : Colors.red,
                    )),
                const SizedBox(width: 5),
                Icon(
                  isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositiveChange ? Colors.green : Colors.red,
                )
              ],
            ),
          ],
        ),
      ),
    );
    ;
  }

  @override
  void initState() {
    super.initState();
    fetchTickers();
  }

  Future<void> fetchTickers() async {
    final response = await http.get(
      Uri.parse('https://api.coinpaprika.com/v1/tickers'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _tickers = data;
        _isLoading = false;
      });
      if (widget.currency == 'EUR') {
        final exchangeResponse = await http.get(
          Uri.parse(
              'https://api.freecurrencyapi.com/v1/latest?apikey=qDxBsrZxK4Z2Dd5eODLmb14Rtkpi9FU9rXYil0KO'),
        );
        if (exchangeResponse.statusCode == 200) {
          final exchangeData = json.decode(exchangeResponse.body)['data'];
          final exchangeRate = exchangeData['EUR'];
          for (var ticker in _tickers) {
            ticker['quotes']['USD']['price'] *= exchangeRate;
          }
          setState(() {
            _tickers = _tickers;
          });
        }
      }
    } else {
      throw Exception('Failed to load tickers');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 770;
    print(screenWidth);

    return MaterialApp(
      title: 'Crypto Tickers',
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 117, 58, 211),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => GoRouter.of(context).go("/"),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualiser',
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                fetchTickers();
              },
            ),
            IconButton(
              icon: Icon(Icons.sort_by_alpha),
              tooltip: 'Trier par ordre alphabétique',
              onPressed: () => _sortData(0),
            ),
            IconButton(
              icon: Icon(Icons.attach_money),
              tooltip: 'Trier par prix',
              onPressed: () => _sortData(1),
            ),
            IconButton(
              icon: Icon(Icons.trending_up),
              tooltip: 'Trier par change',
              onPressed: () => _sortData(2),
            ),
          ],
          title: Text('${widget.currency}'),
          backgroundColor: const Color.fromARGB(255, 53, 13, 118),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : isLargeScreen
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 50.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.75,
                    ),
                    itemCount: _tickers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ticker = _tickers[index];
                      return _card(ticker);
                    },
                  )
                : ListView.builder(
                    itemCount: _tickers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ticker = _tickers[index];
                      return _card(ticker);
                    },
                  ),
      ),
    );
  }
}
