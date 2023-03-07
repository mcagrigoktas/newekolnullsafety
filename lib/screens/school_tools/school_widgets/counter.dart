part of 'school_widget_helper.dart';

class _CounterWidget extends StatefulWidget {
  final WidgetModel model;

  _CounterWidget(this.model) : super(key: ValueKey(model.key));

  @override
  State<_CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<_CounterWidget> {
  late Timer _timer;
  int _time = 0;
  late RemainingTime _remainingTime;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(minutes: 1), _setTime);
    _calculateTime();

    super.initState();
  }

  void _setTime(Timer timer) {
    _calculateTime();
    setState(() {});
  }

  void _calculateTime() {
    _time = widget.model.countTime - DateTime.now().millisecondsSinceEpoch;
    if (_time < 0) _time = 0;
    _remainingTime = _time.remainingTime;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const _dayProgressColor = Color(0xffF6A881);
    const _hourProgressColor = Color(0xff6DCFFF);
    const _minuteProgressColor = Color(0xffA177B0);
    final _customSliderWidth = CustomSliderWidths(trackWidth: 3, progressBarWidth: 4, shadowWidth: 5);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(color: Fav.design.primaryText.withAlpha(5), borderRadius: BorderRadius.circular(9), border: Border.all(width: 0.5, color: Fav.design.primaryText.withAlpha(30))),
      padding: Inset(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _time < 1
              ? 'timesup'.translate.text.maxLines(2).autoSize.fontSize(20).bold.make().center
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: SleekCircularSlider(
                        min: 0,
                        max: 365,
                        initialValue: _remainingTime.day.clamp(0.0, 365.0).toDouble(),
                        appearance: CircularSliderAppearance(
                            customWidths: _customSliderWidth,
                            customColors: CustomSliderColors(
                              dotColor: Colors.white.withOpacity(0.8),
                              trackColor: const Color(0xffFFD4BE).withOpacity(0.4),
                              progressBarColor: _dayProgressColor,
                              shadowColor: const Color(0xffFFD4BE),
                              shadowStep: 3.0,
                              shadowMaxOpacity: 0.6,
                            ),
                            startAngle: 270,
                            angleRange: 360,
                            animationEnabled: false),
                        innerWidget: (double valye) {
                          return SleekCircularSlider(
                            min: 0.0,
                            max: 23.0,
                            initialValue: _remainingTime.hour.clamp(0.0, 23.0).toDouble(),
                            appearance: CircularSliderAppearance(
                                customWidths: _customSliderWidth,
                                customColors: CustomSliderColors(
                                  dotColor: Colors.white.withOpacity(0.8),
                                  trackColor: const Color(0xff98DBFC).withOpacity(0.4),
                                  progressBarColor: _hourProgressColor,
                                  shadowColor: const Color(0xff98DBFC),
                                  shadowStep: 3.0,
                                  shadowMaxOpacity: 0.3,
                                ),
                                startAngle: 270,
                                angleRange: 360,
                                animationEnabled: false),
                            innerWidget: (double valye) {
                              return SleekCircularSlider(
                                min: 0.0,
                                max: 59.0,
                                initialValue: _remainingTime.minute.clamp(0.0, 59.0).toDouble(),
                                appearance: CircularSliderAppearance(
                                  customWidths: _customSliderWidth,
                                  customColors: CustomSliderColors(
                                    dotColor: Colors.white.withOpacity(0.8),
                                    trackColor: const Color(0xffEFC8FC).withOpacity(0.4),
                                    progressBarColor: _minuteProgressColor,
                                    shadowColor: const Color(0xffEFC8FC),
                                    shadowStep: 3.0,
                                    shadowMaxOpacity: 0.3,
                                  ),
                                  startAngle: 270,
                                  angleRange: 360,
                                  animationEnabled: false,
                                ),
                                innerWidget: (value) => Opacity(opacity: 0.3, child: Icons.hourglass_top_rounded.icon.color(GlassIcons.timer.color!).make()),
                              ).p8;
                            },
                          ).p8;
                        },
                      ),
                    ),
                    16.widthBox,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ('${_remainingTime.day} ${'dayhint'.translate}').text.color(_dayProgressColor).maxLines(1).autoSize.fontSize(14).bold.make().px8,
                        ('${_remainingTime.hour} ${'hour'.translate}').text.color(_hourProgressColor).maxLines(1).autoSize.fontSize(14).bold.make().px8,
                        ('${_remainingTime.minute} ${'minute'.translate}').text.color(_minuteProgressColor).maxLines(1).autoSize.fontSize(14).bold.make().px8,
                      ],
                    )
                  ],
                ),
          widget.model.name.text.autoSize.maxLines(2).center.make()
        ],
      ),
    );
  }
}
