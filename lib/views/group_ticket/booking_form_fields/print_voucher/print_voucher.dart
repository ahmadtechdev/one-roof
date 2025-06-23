// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PDFPrintScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const PDFPrintScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    // Print complete data in console
    _printCompleteData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Ticket'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with date and company
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getCurrentDateTime(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'ONE ROOF TRAVEL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Booking details row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column - booking info
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabelValue(
                              'PNR',
                              _getPNR(),
                              Colors.blue.shade900,
                            ),
                            const SizedBox(height: 12),
                            _buildLabelValue(
                              'Booking #',
                              _getBookingId(),
                              Colors.blue.shade900,
                            ),
                            const SizedBox(height: 12),
                            _buildLabelValue(
                              'Booked By',
                              'ONE ROOF TRAVEL',
                              Colors.blue.shade900,
                            ),
                            const SizedBox(height: 12),
                            _buildLabelValue(
                              'Contact',
                              _getMobile(),
                              Colors.blue.shade900,
                            ),
                            const SizedBox(height: 12),
                            _buildStatusWidget(),
                          ],
                        ),
                      ),

                      // Right column - airline info
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal.shade200),
                          ),
                          child: Text(
                            _getAirlineInfo(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Flight Details Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header with orange accent
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.orange, width: 4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Flight Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            'Booking Date: ${_getCurrentDateTime()}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flight Table
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        // Header Row
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Flight No.',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  'Flight Info',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Baggage',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Meal',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Data Row
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                          ),
                          child: Row(
                            children: [
                              // Flight Number
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _getFlightNumber(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Date
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _getShortDate(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Flight Info
                              Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Route with arrow
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Departure city
                                        Flexible(
                                          child: Text(
                                            _getDepartureCity(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade300,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),

                                        // Arrow with minimal spacing
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.orange.shade300,
                                            size: 8,
                                          ),
                                        ),

                                        // Arrival city
                                        Flexible(
                                          child: Text(
                                            _getArrivalCity(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade300,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 2),

                                    // Times
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _getDepartureTime(),
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        Text(
                                          ' - ',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),

                                        Flexible(
                                          child: Text(
                                            _getArrivalTime(),
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Baggage
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _getBaggageInfo(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),

                              // Meal
                              Expanded(
                                flex: 1,
                                child: Text(
                                  _getMealInfo(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Passenger info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Passengers Information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Display passenger details
                        ..._buildPassengersList(),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Total Passengers: ${_getPassengerCount()}',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getStatus(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Total fare
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       'Total Fare:',
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.grey.shade800,
                        //       ),
                        //     ),
                        //     Text(
                        //       'PKR ${_getTotalFare()}',
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.green.shade700,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Terms & Conditions Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.orange, width: 4),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'TERMS & CONDITIONS:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildBulletPoint(
                    'Passenger should report at check-in counter at least 4:00 hours prior to the flight.',
                  ),

                  const SizedBox(height: 8),

                  _buildBulletPoint(
                    'After confirmation, tickets are non-refundable and non-changeable at any time.',
                  ),

                  const SizedBox(height: 8),

                  _buildBulletPoint(
                    'Valid passport and visa (if required) must be presented at check-in.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Print Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.print, size: 24),
                label: const Text(
                  'Print Ticket',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  try {
                    await Printing.layoutPdf(
                      onLayout: (format) => generateFlightTicket(),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Printing failed: $e'),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Print complete data in console
  void _printCompleteData() {

    // Print formatted JSON
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    encoder.convert(bookingData);


    // Print passenger details
    final passengers = _getPassengerDetails();
    for (int i = 0; i < passengers.length; i++) {
    }

  }

  List<Widget> _buildPassengersList() {
    final passengers = _getPassengerDetails();
    List<Widget> widgets = [];

    for (int i = 0; i < passengers.length; i++) {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(i + 1).toString()}. ${passengers[i]['name']}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  Text(
                    '${passengers[i]['type']}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Passport: ${passengers[i]['passport']} | ',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  Text(
                    'DOB: ${passengers[i]['dob']}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DOE: ${passengers[i]['doe']}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  Text(
                    _getStatus(),
                    // 'Fare: PKR ${NumberFormat('#,##0').format(passengers[i]['fare'])}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildLabelValue(String label, String value, Color labelColor) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label\n',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusWidget() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Status\n',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          TextSpan(
            text: _getStatus(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade600,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // Data extraction methods
  String _getPNR() {
    try {
      return bookingData['data']?['data']?['group']?['pnr']?.toString() ??
          'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getSector() {
    try {
      return bookingData['data']?['data']?['group']?['sector']?.toString() ??
          'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getFlightNumber() {
    try {
      final airline = bookingData['data']?['data']?['group']?['airline'];

      return airline?['short_name']?.toString() ?? 'ER';
    } catch (e) {
      return 'ER';
    }
  }

  String _getShortDate() {
    try {
      final deptDate = bookingData['data']?['data']?['group']?['dept_date'];
      if (deptDate != null) {
        final date = DateTime.parse(deptDate);
        return DateFormat('dd MMM').format(date);
      }
      return DateFormat('dd MMM').format(DateTime.now());
    } catch (e) {
      return DateFormat('dd MMM').format(DateTime.now());
    }
  }

  String _getDepartureCity() {
    try {
      final sector = _getSector();
      if (sector.contains('TO')) {
        return sector.split('TO')[0].trim();
      }
      return 'UNKNOWN';
    } catch (e) {
      return 'UNKNOWN';
    }
  }

  String _getArrivalCity() {
    try {
      final sector = _getSector();
      if (sector.contains('TO')) {
        return sector.split('TO')[1].trim();
      }
      return 'UNKNOWN';
    } catch (e) {
      return 'UNKNOWN';
    }
  }

  String _getDepartureTime() {
    try {
      // Since departure time is not in the data, we'll use a default
      return '02:10';
    } catch (e) {
      return '02:10';
    }
  }

  String _getArrivalTime() {
    try {
      // Since arrival time is not in the data, we'll use a default
      return '04:40';
    } catch (e) {
      return '04:40';
    }
  }

  String _getStatus() {
    try {
      final status = bookingData['data']?['data']?['status'] ?? 0;
      return status == 1 ? 'Confirmed' : 'Hold';
    } catch (e) {
      return 'Hold';
    }
  }



  String _getAirlineInfo() {
    try {
      final airline = bookingData['data']?['data']?['group']?['airline'];
      final airlineName = airline?['airline_name']?.toString() ?? 'N/A';
      final shortName = airline?['short_name']?.toString() ?? 'N/A';
      return '$shortName\n$airlineName';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMealInfo() {
    try {
      final meal = bookingData['data']?['data']?['group']?['meal'];
      return meal != null && meal.toString().toLowerCase() == 'yes'
          ? 'Yes'
          : 'No';
    } catch (e) {
      return 'No';
    }
  }

  String _getBaggageInfo() {
    try {
      final baggage = bookingData['data']?['data']?['group']?['baggage'];
      return baggage?.toString() ?? '20+7 KG';
    } catch (e) {
      return '20+7 KG';
    }
  }

  String _getCurrentDateTime() {
    return DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.now());
  }

  String _getPassengerCount() {
    try {
      final adults = bookingData['data']?['data']?['adults'] ?? 0;
      final children = bookingData['data']?['data']?['child'] ?? 0;
      final infants = bookingData['data']?['data']?['infant'] ?? 0;

      List<String> parts = [];
      if (adults > 0) parts.add('$adults Adult${adults > 1 ? 's' : ''}');
      if (children > 0) {
        parts.add('$children Child${children > 1 ? 'ren' : ''}');
      }
      if (infants > 0) parts.add('$infants Infant${infants > 1 ? 's' : ''}');

      return parts.isNotEmpty ? parts.join(', ') : '0';
    } catch (e) {
      return '0';
    }
  }

  String _getBookingId() {
    try {
      return bookingData['data']?['data']?['id']?.toString() ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMobile() {
    try {
      return bookingData['data']?['data']?['mobile']?.toString() ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  List<Map<String, dynamic>> _getPassengerDetails() {
    try {
      final passengers = bookingData['data']?['data']?['passengers'] as List?;
      if (passengers == null) return [];

      return passengers.map((passenger) {
        return {
          'name':
              '${passenger['given_name'] ?? ''} ${passenger['surname'] ?? ''}',
          'type': passenger['type'] ?? 'Adult',
          'passport': passenger['passport_no'] ?? 'N/A',
          'dob': _formatDate(passenger['dob']),
          'doe': _formatDate(passenger['doe']),
          'fare': passenger['fare'] ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String _formatDate(String? dateStr) {
    try {
      if (dateStr == null) return 'N/A';
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr ?? 'N/A';
    }
  }

  // PDF Generation Function
  Future<Uint8List> generateFlightTicket() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build:
            (pw.Context context) => [
              // Header Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header row with date and company
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          _getCurrentDateTime(),
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          'ONE ROOF TRAVEL',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 16),

                    // Booking details row
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left column - booking info
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildPdfLabelValue('PNR', _getPNR()),
                              pw.SizedBox(height: 8),
                              _buildPdfLabelValue('Booking #', _getBookingId()),
                              pw.SizedBox(height: 8),
                              _buildPdfLabelValue(
                                'Booked By',
                                'ONE ROOF TRAVEL',
                              ),
                              pw.SizedBox(height: 8),
                              _buildPdfLabelValue('Contact', _getMobile()),
                              pw.SizedBox(height: 8),
                              _buildPdfLabelValue('Status', _getStatus()),
                            ],
                          ),
                        ),

                        pw.SizedBox(width: 20),

                        // Right column - airline info
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.teal50,
                              border: pw.Border.all(color: PdfColors.teal200),
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Text(
                              _getAirlineInfo(),
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.teal700,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Flight Details Section
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Section header
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          left: pw.BorderSide(
                            color: PdfColors.orange,
                            width: 4,
                          ),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Flight Details',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                          pw.Text(
                            'Booking Date: ${_getCurrentDateTime()}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Flight Table
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey400),
                      children: [
                        // Header Row
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue700,
                          ),
                          children: [
                            _buildPdfTableHeader('Flight No.'),
                            _buildPdfTableHeader('Date'),
                            _buildPdfTableHeader('Flight Info'),
                            _buildPdfTableHeader('Baggage'),
                            _buildPdfTableHeader('Meal'),
                          ],
                        ),

                        // Data Row
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey800,
                          ),
                          children: [
                            _buildPdfTableCell(
                              _getFlightNumber(),
                              PdfColors.white,
                            ),
                            _buildPdfTableCell(
                              _getShortDate(),
                              PdfColors.white,
                            ),
                            _buildPdfFlightInfoCell(),
                            _buildPdfTableCell(
                              _getBaggageInfo(),
                              PdfColors.white,
                            ),
                            _buildPdfTableCell(_getMealInfo(), PdfColors.white),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 16),

                    // Passenger Information
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Passengers Information',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                          pw.SizedBox(height: 8),

                          // Passenger details
                          ..._buildPdfPassengersList(),

                          pw.SizedBox(height: 12),

                          // Total passengers and status
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Total Passengers: ${_getPassengerCount()}',
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.green50,
                                  borderRadius: pw.BorderRadius.circular(4),
                                ),
                                child: pw.Text(
                                  _getStatus(),
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    color: PdfColors.green700,
                                    fontWeight: pw.FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          pw.SizedBox(height: 12),

                          // Total fare
                          // pw.Row(
                          //   mainAxisAlignment:
                          //       pw.MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     pw.Text(
                          //       'Total Fare:',
                          //       style: pw.TextStyle(
                          //         fontSize: 14,
                          //         fontWeight: pw.FontWeight.bold,
                          //         color: PdfColors.grey800,
                          //       ),
                          //     ),
                          //     pw.Text(
                          //       'PKR ${_getTotalFare()}',
                          //       style: pw.TextStyle(
                          //         fontSize: 14,
                          //         fontWeight: pw.FontWeight.bold,
                          //         color: PdfColors.green700,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Terms & Conditions Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          left: pw.BorderSide(
                            color: PdfColors.orange,
                            width: 4,
                          ),
                        ),
                      ),
                      padding: const pw.EdgeInsets.only(left: 8),
                      child: pw.Text(
                        'TERMS & CONDITIONS:',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ),

                    pw.SizedBox(height: 12),

                    _buildPdfBulletPoint(
                      'Passenger should report at check-in counter at least 4:00 hours prior to the flight.',
                    ),

                    pw.SizedBox(height: 8),

                    _buildPdfBulletPoint(
                      'After confirmation, tickets are non-refundable and non-changeable at any time.',
                    ),

                    pw.SizedBox(height: 8),

                    _buildPdfBulletPoint(
                      'Valid passport and visa (if required) must be presented at check-in.',
                    ),
                  ],
                ),
              ),
            ],
      ),
    );

    return pdf.save();
  }

  // PDF Helper Methods
  pw.Widget _buildPdfLabelValue(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey800),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, color: color),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPdfFlightInfoCell() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          // Route
          pw.Text(
            '${_getDepartureCity()} → ${_getArrivalCity()}',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange300,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 2),
          // Times
          pw.Text(
            '${_getDepartureTime()} - ${_getArrivalTime()}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.white),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildPdfPassengersList() {
    final passengers = _getPassengerDetails();
    List<pw.Widget> widgets = [];

    for (int i = 0; i < passengers.length; i++) {
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey200),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${passengers[i]['name']}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.Text(
                    '${passengers[i]['type']}',
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Passport: ${passengers[i]['passport']} | DOB: ${passengers[i]['dob']}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'DOE: ${passengers[i]['doe']}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    _getStatus(),
                    // 'Fare: PKR ${NumberFormat('#,##0').format(passengers[i]['fare'])}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.normal,
                      color: PdfColors.green700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  pw.Widget _buildPdfBulletPoint(String text) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 6),
          width: 4,
          height: 4,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey600,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
        ),
      ],
    );
  }
}
