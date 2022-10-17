
import 'package:flutter/material.dart';
import 'package:paw_pals/widgets/empty_screen_card.dart';
import 'package:paw_pals/widgets/screencards.dart';
import 'package:paw_pals/widgets/bars/our_app_bar.dart';


/// This is an example of a simple screen that extends a [StatelessWidget]
/// Yes, technically the screen is a widget, but it's best to treat it like
/// a place to organize widgets.
///
///


class FeedScreen extends StatelessWidget {
  final String screenTitle = "Feed Screen";

  //final String exampleText = "Feed Would be imported Here\n\n\n\n\n\n\n\n\n\n\n";
  //final String buttonLabelLeft = "left swipe (For Later)";
  //final String buttonLabelRight = "right swipe (For Later)";


  // This is the constructor. All widgets should have a Key key as optional
  // parameter in their constructor. Key is something used by flutter engine
  // at the step of recognizing which widget in a list as changed.
  const FeedScreen({super.key});





  // You must call @override on the build method
  @override
  Widget build(BuildContext context) {
    // Every screen will use a scaffold as the outer-most widget.
    return Scaffold(
      // The bar that goes across the top of the screen:

      appBar: OurAppBar.build(screenTitle),
      body: Column(
        children: [

          Draggable(
            child: ScreenCards(color: Colors.red,),
            feedback: ScreenCards(color: Colors.red,),
            childWhenDragging: EmptyCard(color: Colors.grey,),
            onDragEnd: (drag){
              if (drag.velocity.pixelsPerSecond.dx < 500 &&
                  drag.velocity.pixelsPerSecond.dx > -500){

                print('Stay');

              } else if (drag.velocity.pixelsPerSecond.dx >500 ) {

                print('Swiped right');
              } else  {
                print('Swiped left');
                print(drag.velocity.pixelsPerSecond.dx);
                print(drag.velocity.pixelsPerSecond.distance);
                print(drag.velocity.pixelsPerSecond.direction);
              }

            },
          )
        ]
      )
    );


  }
}