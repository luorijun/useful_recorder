import 'package:flutter/material.dart';

typedef RatingEvent(int index);

class RatingListTile extends StatelessWidget {
  final Widget title;
  final IconData icon;
  final int count;
  final int selected;
  final Color color;
  final RatingEvent onRating;
  final bool dense;

  const RatingListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.count,
    required this.selected,
    required this.color,
    required this.onRating,
    this.dense = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      dense: dense,
      trailing: Wrap(
        children: List.generate(
          count,
          (index) => IconButton(
            icon: Icon(
              icon,
              color: index < selected ? color : Colors.grey,
              size: dense ? 20 : 24,
            ),
            padding: EdgeInsets.all(4),
            onPressed: () {
              return onRating.call(index + 1);
            },
          ),
        ),
      ),
    );
  }
}

typedef VoteEvent(int index);

class VoteListTile extends StatelessWidget {
  final Widget title;
  final List<IconData> icons;
  final int selected;
  final Color color;
  final VoteEvent onVote;

  const VoteListTile({
    Key? key,
    required this.title,
    required this.icons,
    required this.selected,
    required this.color,
    required this.onVote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      trailing: Wrap(
        children: List.generate(
          icons.length,
          (index) => IconButton(
            icon: Icon(
              icons[index],
              color: selected == index + 1 ? color : Colors.grey,
            ),
            color: Colors.grey,
            onPressed: () {
              onVote.call(index + 1);
            },
          ),
        ),
      ),
    );
  }
}
