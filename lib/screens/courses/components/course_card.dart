
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String image, title, details, students, price;
  final double rating;

  CourseCard(
      {required this.image,
      required this.title,
      required this.rating,
      required this.details,
      required this.students,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // بدّل الأبيض بكده
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 4,
            spreadRadius: 1.5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, height: 100, fit: BoxFit.cover),
          ),
          SizedBox(height: 8),
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber),
              Text(' $rating')
            ],
          ),
          Text(details, style: TextStyle(color: Colors.grey.shade600)),
          Text(students, style: TextStyle(color: Colors.grey.shade600)),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price,
                  style: TextStyle(
                      color: price == 'Free'
                          ? Colors.green
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'View More',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
