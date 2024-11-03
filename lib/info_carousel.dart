import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class InfoCarousel extends StatefulWidget {
  const InfoCarousel({super.key});

  @override
  InfoCarouselState createState() => InfoCarouselState();
}

class InfoCarouselState extends State<InfoCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.blue,
          height: 200,
          child: CarouselSlider(
            options: CarouselOptions(
              autoPlayInterval: const Duration(seconds: 3),
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              viewportFraction: 0.8,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: [
              _buildCarouselItem('Imagem 1', Colors.lightBlueAccent),
              _buildCarouselItem('Imagem 2', Colors.lightBlue),
              _buildCarouselItem('Imagem 3', Colors.blueAccent),
            ],
          ),
        ),
        const SizedBox(height: 15),
        _buildPageIndicators(3),
      ],
    );
  }

  Widget _buildCarouselItem(String text, Color color) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPageIndicators(int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index ? Colors.black : Colors.grey,
          ),
        );
      }),
    );
  }
}
