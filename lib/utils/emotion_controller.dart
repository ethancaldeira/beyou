import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controller.dart';

//The class allows us to use the FlareController and make an animation more wiht a slider.
//Used for the mood check ins animation.
//Code adapted from tutorial: https://www.youtube.com/watch?v=4RHvFVVUWqw
class MoodController extends FlareController {
  //Has the animation blink
  late ActorAnimation blink;
  //Creates the timer for the blinking animation.
  double timer = 0;
  @override
  //We need to set up the artboard for the animation
  void initialize(FlutterActorArtboard artboard) {
    blink = artboard.getAnimation('blink')!; //We set the animation to blink.
  }

  //This method allows us to change the animations state.
  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    //Increases the timer.
    timer += elapsed;
    //Blinks with the when the timer has passted a value.
    blink.apply(timer % blink.duration, artboard, 0.5);
    //return true as the animation should have blinked.
    return true;
  }

  //Need relay the information regarding what the controller is attached too.
  @override
  void setViewTransform(Mat2D viewTransform) {}
}
