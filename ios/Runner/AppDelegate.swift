import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    var imageview : UIImageView?

    override func applicationWillResignActive(_ application: UIApplication) {
        self.window?.isHidden = true
            //imageview = UIImageView.init(image: UIImage.init(named: "bg_splash"))
            //self.window?.addSubview(imageview!)
            // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
            // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        self.window?.isHidden = false
            /*if (imageview != nil){

                imageview?.removeFromSuperview()
                imageview = nil
            }*/
            // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        }
    
    /*- (void)applicationWillResignActive:(UIApplication *)application{
        self.window.isHidden = YES;
    }

    - (void)applicationDidBecomeActive:(UIApplication *)application{
        self.window.hidden = NO;
    }*/
}
