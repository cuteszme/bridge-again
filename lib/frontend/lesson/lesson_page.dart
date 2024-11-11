import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

class LessonPage extends StatefulWidget {
  final String lessonTitle;

  const LessonPage({super.key, required this.lessonTitle});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _lessonContent = [
 {
      'title': 'Introduction to Baybayin',
      'content': '''
Baybayin is an ancient Philippine script used primarily by the Tagalog people before the Spanish colonial period. This writing system was widely used in Luzon and other parts of the Philippines during the 16th and 17th centuries.

Learning Objectives:
• Understand the historical context of Baybayin
• Learn the basic character set
• Master the krus-kudlit system
• Practice writing simple words
• Appreciate its cultural significance
      ''',
    },
    {
      'title': 'Historical Overview',
      'content': '''
Key Points:
• Developed around the 13th century
• Widely used for personal writings and correspondence
• Nearly disappeared during Spanish colonization
• Experiencing revival in modern Filipino culture

Cultural Significance:
• Symbol of pre-colonial Filipino literacy
• Represents indigenous Filipino identity
• Used in modern art, tattoos, and design
      ''',
    },
    {
      'title': 'Basic Characters',
      'content': '''
Baybayin Basics:
• 17 basic characters
• Each character represents a syllable
• Three vowel markers
• No special characters for foreign sounds

Common Characters:
ᜀ (a) - pronounced as "ah"
ᜊ (ba) - pronounced as "bah"
ᜃ (ka) - pronounced as "kah"
ᜇ (da) - pronounced as "dah"
ᜄ (ga) - pronounced as "gah"
ᜑ (ha) - pronounced as "hah"
ᜎ (la) - pronounced as "lah"
ᜋ (ma) - pronounced as "mah"
ᜈ (na) - pronounced as "nah"
ᜅ (nga) - pronounced as "ngah"
ᜉ (pa) - pronounced as "pah"
ᜐ (sa) - pronounced as "sah"
ᜆ (ta) - pronounced as "tah"
ᜏ (wa) - pronounced as "wah"
ᜌ (ya) - pronounced as "yah"
      ''',
    },
    {
      'title': 'The Krus-Kudlit System',
      'content': '''
Understanding Krus-Kudlit:
• Essential diacritical marks in Baybayin
• Used to modify vowel sounds in consonant characters
• Two types: the kudlit (dot or tick) and krus (cross)

Vowel Modifications:
• Default sound: A (no mark needed)
• I/E sound: Add kudlit above character (˙)
• O/U sound: Add kudlit below character (.)

Example Transformations:
ᜊ (ba) → ᜊᜒ (bi/be) → ᜊᜓ (bo/bu)
ᜃ (ka) → ᜃᜒ (ki/ke) → ᜃᜓ (ko/ku)
ᜇ (da) → ᜇᜒ (di/de) → ᜇᜓ (do/du)

Common Words Using Krus-Kudlit:
• ᜊᜓᜃᜒᜇ᜔ (bukid) - mountain
• ᜇᜒᜎᜒ (dili) - no/not
• ᜊᜓᜎᜃ᜔ (bulak) - flower

Importance in Writing:
• Essential for accurate pronunciation
• Affects word meaning and comprehension
• Key to proper written communication
• Preserves intended message clarity
      ''',
    },
    {
      'title': 'Krus-Kudlit Practice',
      'content': '''
Practice Guidelines:
• Start with single character modifications
• Progress to full words
• Pay attention to placement of marks
• Practice both reading and writing

Common Mistakes to Avoid:
• Incorrect mark placement
• Missing required marks
• Mixing up I/E and O/U marks
• Inconsistent mark sizes

Tips for Mastery:
• Practice writing characters large at first
• Use guide points for mark placement
• Write words you commonly use
• Create practice sentences
      ''',
    },  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple[50]!, Colors.deepPurple[100]!],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _lessonContent.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _lessonContent[index]['title'],
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _lessonContent[index]['content'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (index == _lessonContent.length - 1)
                          Card(
                            margin: const EdgeInsets.only(top: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Practice Area',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Practice writing Baybayin characters with krus-kudlit...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Navigation dots
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _lessonContent.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.deepPurple : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            // Lesson Complete Button (only shown on the last page)
            if (_currentPage == _lessonContent.length - 1)
              LessonCompleteButton(
                onPressed: () {
                  Provider.of<AppState>(context, listen: false).completeLesson(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lesson Completed!')),
                  );
                  // Add any additional completion logic here
                },
              ),
            // Additional Resources Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Resources',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '• National Museum of the Philippines - Baybayin Collection\n'
                            '• Philippine Indigenous Writing Systems\n'
                            '• Modern Baybayin Art and Applications\n'
                            '• Online Baybayin Learning Communities\n'
                            '• Krus-Kudlit Writing Guides',
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book),
                label: const Text('Additional Resources'),
              ),
            ),
          ],
        ),
      )
      );
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class LessonCompleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LessonCompleteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        icon: const Icon(Icons.check, size: 24),
        label: const Text(
          'Completed',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}