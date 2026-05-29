//
//  SceneDelegate.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/2.
//

#import "SceneDelegate.h"
#import "pages/MainNavController.h"
#import "ViewController.h"
#import "login/LoginController.h"
#import "login/LoginNavController.h"
#import "pages/MainTabBarController.h"
#import "Tools/BLEManager.h"
#import "Tools/DataCenter.h"
@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)applySimulatorDefaultDevice
{
#if TARGET_OS_SIMULATOR
    BedModel *bed = [[BedModel alloc] init];
    bed.mode = BedNormal;
    bed.bedName = @"AI Adaptive Mattress Pro";
    [DataCenter shareInstance].connectedBed = bed;
    [BLEManager shareInstance].mode = BedNormal;
#endif
}


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    [self applySimulatorDefaultDevice];
    
//    MainTabBarController *mainTabBarVC = [[MainTabBarController alloc] init];
//    self.window.rootViewController = mainTabBarVC;
//    [self.window makeKeyAndVisible];
    
    LoginController *loginVC = [[LoginController alloc] init];
    LoginNavController *loginNav = [[LoginNavController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = loginNav;
    
//    ViewController *vc = [[ViewController alloc] init];
//    MainNavController *navController = [[MainNavController alloc] initWithRootViewController:vc];
//    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
}


- (void)changeYellowController
{
    [self applySimulatorDefaultDevice];
    MainTabBarController *mainTabBarVC = [[MainTabBarController alloc] init];
    self.window.rootViewController = mainTabBarVC;
    [self.window makeKeyAndVisible];
}





- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
