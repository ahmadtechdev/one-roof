// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml2json/xml2json.dart';

class FlightShoppingService {
  final String link = 'https://otatest2.zapways.com/v2.0/OTAAPI.asmx';
  final String sslCert = 'https://agent1.pk/flight/classes/toc/cert.pem';
  final String sslKey = 'https://agent1.pk/flight/classes/toc/key.pem';
  final String airsslCert = 'https://agent1.pk/flight/classes/toc/cert.pem';
  final String airsslKey = 'https://agent1.pk/flight/classes/toc/key.pem';
  final String ERSP_UserID = '2012/86B5EFDFF02E2966CBB6EECFF6FC339222';
  final String ID = 'travelocityota';
  final String MessagePassword = 'nRve2!EzPrc4cdvt';
  final String Target = 'Test';
  final String Version = '1.04';
  final String Type = '29';

  Future<Map<String, dynamic>> airBlueFlightSearch({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required String stop,
    required String cabin,
  }) async {
    try {
      // Process input parameters exactly like PHP version
      final originArray = origin.split(",");
      final destinationArray = destination.split(",");
      final depDateArray = depDate.split(",");
      //
      // print("Origins");
      // print(originArray);
      // print("destiantions");
      // print(destinationArray);
      // print("dates");
      // print(depDateArray);

      String originDestination = "";
      String cabins = 'Y'; // Default to Economy

      // Cabin type mapping
      switch (cabin) {
        case 'Economy':
          cabins = 'Y';
          break;
        case 'Business':
          cabins = 'C';
          break;
        case 'First-Class':
          cabins = 'F';
          break;
      }

      // Build origin destination XML exactly like PHP version
      if (type == 0) {
        // One-way trip
        originDestination = '''
  <OriginDestinationInformation RPH="1">
    <DepartureDateTime>${depDateArray[1]}T00:00:00</DepartureDateTime>
    <OriginLocation LocationCode="${originArray[1].toUpperCase()}"></OriginLocation>
    <DestinationLocation LocationCode="${destinationArray[1].toUpperCase()}"></DestinationLocation>
  </OriginDestinationInformation>''';
      } else if (type == 1) {
        // Round trip
        originDestination = '''
  <OriginDestinationInformation RPH="1">
    <DepartureDateTime>${depDateArray[1]}T00:00:00</DepartureDateTime>
    <OriginLocation LocationCode="${originArray[1].toUpperCase()}"></OriginLocation>
    <DestinationLocation LocationCode="${destinationArray[1].toUpperCase()}"></DestinationLocation>
  </OriginDestinationInformation>
  <OriginDestinationInformation RPH="2">
    <DepartureDateTime>${depDateArray[2]}T00:00:00</DepartureDateTime>
    <OriginLocation LocationCode="${destinationArray[1].toUpperCase()}"></OriginLocation>
    <DestinationLocation LocationCode="${originArray[1].toUpperCase()}"></DestinationLocation>
  </OriginDestinationInformation>''';
      } else if (type == 2) {
        // Multi-city trip
        final loopCount = originArray.length;
        for (int i = 1; i < loopCount; i++) {
          originDestination += '''
  <OriginDestinationInformation RPH="$i">
    <DepartureDateTime>${depDateArray[i]}T00:00:00</DepartureDateTime>
    <OriginLocation LocationCode="${originArray[i].toUpperCase()}"></OriginLocation>
    <DestinationLocation LocationCode="${destinationArray[i].toUpperCase()}"></DestinationLocation>
  </OriginDestinationInformation>''';
        }
      }

      // Build passenger XML exactly like PHP version
      String passengerArray = '';
      if (adult != 0) {
        passengerArray += '<PassengerTypeQuantity Code="ADT" Quantity="$adult"></PassengerTypeQuantity>';
      }
      if (child != 0) {
        passengerArray += '<PassengerTypeQuantity Code="CHD" Quantity="$child"></PassengerTypeQuantity>';
      }
      if (infant != 0) {
        passengerArray += '<PassengerTypeQuantity Code="INF" Quantity="$infant"></PassengerTypeQuantity>';
      }

      // Generate random string for EchoToken (similar to PHP function)
      final randomString = _generateRandomString(32);

      // Build the complete XML request exactly like PHP version
      final request = '''<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
  <Header/>
  <Body>
    <AirLowFareSearch xmlns="http://zapways.com/air/ota/2.0">
      <airLowFareSearchRQ EchoToken="$randomString" Target="$Target" Version="$Version" xmlns="http://www.opentravel.org/OTA/2003/05">
        <POS>
          <Source ERSP_UserID="$ERSP_UserID">
            <RequestorID Type="$Type" ID="$ID" MessagePassword="$MessagePassword" />
          </Source>
        </POS>
        $originDestination
        <TravelerInfoSummary>
          <AirTravelerAvail>
            $passengerArray
          </AirTravelerAvail>
        </TravelerInfoSummary>
      </airLowFareSearchRQ>
    </AirLowFareSearch>
  </Body>
</Envelope>''';

      // print("request");
      final xmlRequest = request.toString();
      final jsonRequest = _convertXmlToJson(xmlRequest);
      // _printJsonPretty(jsonRequest);

      // Log the request (matching PHP format)
      // await _logRequest(request, 'Shopping_request');

      // Configure Dio with SSL certificates
      final ByteData certData = await rootBundle.load('assets/certs/cert.pem');
      final ByteData keyData = await rootBundle.load('assets/certs/key.pem');

      // Create temporary files for the certificates
      final Directory tempDir = await getTemporaryDirectory();
      final File certFile = File('${tempDir.path}/cert.pem');
      final File keyFile = File('${tempDir.path}/key.pem');

      await certFile.writeAsBytes(certData.buffer.asUint8List());
      await keyFile.writeAsBytes(keyData.buffer.asUint8List());

      // Configure Dio with SSL certificates
      final dio = Dio(
        BaseOptions(
          contentType: 'text/xml; charset=utf-8',
          headers: {'Content-Type': 'text/xml; charset=utf-8'},
        ),
      );

      // Create SecurityContext with certificates
      final SecurityContext securityContext = SecurityContext();
      securityContext.useCertificateChain(certFile.path);
      securityContext.usePrivateKey(keyFile.path);

      // Configure HttpClient with the security context
      final HttpClient httpClient = HttpClient(context: securityContext);
      httpClient.badCertificateCallback = (
          X509Certificate cert,
          String host,
          int port,
          ) {
        return true; // Only use this for testing! In production, implement proper validation
      };

      // Create the Dio client with the custom HttpClient
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () => httpClient,
      );

      // Make the API call
      final response = await dio.post(
        link,
        data: request,
        options: Options(
          contentType: 'text/xml; charset=utf-8',
          responseType: ResponseType.plain,
        ),
      );
      // Convert XML to JSON using xml2json package
      final xmlResponse = response.data.toString();
      final jsonResponse = _convertXmlToJson(xmlResponse);

      // print("response");
      // _printJsonPretty(jsonResponse);


      // Log the response (matching PHP format)
      // await _logResponse(response.data.toString(), 'Shopping_response');

      // Convert XML to JSON
      return _convertXmlToJson(response.data.toString());
    } catch (e) {
      // print('Error in shoppingFlight: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _convertXmlToJson(String xmlString) {
    try {
      final transformer = Xml2Json();
      transformer.parse(xmlString);
      final jsonString = transformer.toGData();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // print('Error converting XML to JSON: $e');
      return {'error': 'Failed to parse XML response'};
    }
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghij   klmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void _printJsonPretty(dynamic jsonData) {
    const int chunkSize = 1000;
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    for (int i = 0; i < jsonString.length; i += chunkSize) {
      print(jsonString.substring(
          i,
          i + chunkSize > jsonString.length
              ? jsonString.length
              : i + chunkSize));
    }
  }

}