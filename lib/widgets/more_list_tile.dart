import 'package:flutter/material.dart';

typedef RatingEvent(int index);

class RatingListTile extends StatelessWidget {
  const RatingListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.max,
    this.score = 0,
    this.color,
    this.onRating,
    this.dense = false,
  }) : super(key: key);

  final Widget title;
  final IconData icon;
  final int max;
  final int score;
  final Color? color;
  final RatingEvent? onRating;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: title,
      dense: dense,
      trailing: Wrap(
        children: List.generate(
          max,
          (index) => IconButton(
            icon: Icon(
              icon,
              color: index < score
                  ? color != null
                      ? color
                      : theme.colorScheme.primary
                  : theme.colorScheme.tertiary,
              size: 24,
            ),
            onPressed: () {
              return onRating?.call(index + 1);
            },
          ),
        ),
      ),
    );
  }
}

typedef VoteEvent(int index);

class VoteListTile extends StatelessWidget {
  const VoteListTile({
    Key? key,
    required this.title,
    required this.icons,
    this.selected = 0,
    this.color,
    this.onVote,
  }) : super(key: key);

  final Widget title;
  final List<IconData> icons;
  final int selected;
  final Color? color;
  final VoteEvent? onVote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: title,
      trailing: Wrap(
        children: List.generate(
          icons.length,
          (index) => IconButton(
            icon: Icon(
              icons[index],
              color: selected == index + 1
                  ? color != null
                      ? color
                      : theme.colorScheme.primary
                  : theme.colorScheme.tertiary,
              size: 24,
            ),
            onPressed: () {
              onVote?.call(index + 1);
            },
          ),
        ),
      ),
    );
  }
}
