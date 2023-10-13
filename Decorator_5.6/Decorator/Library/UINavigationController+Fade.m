/*
Copied and pasted from David Hamrick's blog:

Source: http://www.davidhamrick.com/2011/12/31/Changing-the-UINavigationController-animation-style.html
*/

@implementation UINavigationController (Fade)

- (void)pushFadeViewController:(UIViewController *)viewController
{
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
//        [self pushViewController:viewController animated:YES];
//    } else {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type = kCATransitionFade;
        [self.view.layer addAnimation:transition forKey:nil];

        [self pushViewController:viewController animated:NO];
//    }
}

- (void)fadePopViewController
{
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
//        [self popViewControllerAnimated:YES];
//    } else {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionFade;
        [self.view.layer addAnimation:transition forKey:nil];
        [self popViewControllerAnimated:NO];
//    }
}

- (void)fadePopRootViewController{
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
//        [self popToRootViewControllerAnimated:YES];
//    } else {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionFade;
        [self.view.layer addAnimation:transition forKey:nil];
        [self popToRootViewControllerAnimated:NO];
//    }
}
@end
