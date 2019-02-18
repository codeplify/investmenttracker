import UIKit
import CoreData
import AWSCognitoIdentityProvider

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate  {
  
  var window: UIWindow?
  var signInViewController: LoginViewController?
  var storyboard: UIStoryboard?
  var navigationController: UINavigationController?
    var rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        if let splitViewController = window!.rootViewController as? UISplitViewController {
            let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
            navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            splitViewController.preferredDisplayMode = .allVisible
            splitViewController.delegate = self
         
            UISearchBar.appearance().tintColor = .candyGreen
            UINavigationBar.appearance().tintColor = .candyGreen
        }
    
    AWSDDLog.sharedInstance.logLevel = .verbose
    let serviceConfiguration = AWSServiceConfiguration(region: CIUserPoolRegion, credentialsProvider: nil)
    let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: CIPoolAppClientID,
                                                                    clientSecret: CIPoolAppClientSecret,
                                                                    poolId: CIPoolID)
    AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: AWSCognitoSigninProviderKey)
    let pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoSigninProviderKey)
    self.storyboard = UIStoryboard(name: "Main", bundle: nil)
    pool.delegate = self
   
    return true
  }
    
  /**
     COREDATA:
     
     */
  lazy var persistentContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "XStockDBModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
  }()
    
  func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
  }
  
  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
    guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
    guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailCandy == nil {
            //Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
    return false
  }
    
    
   
}


extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        if self.navigationController == nil {
            self.navigationController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? UINavigationController
        }
        
        if self.signInViewController == nil {
            self.signInViewController = self.navigationController?.viewControllers[0] as? LoginViewController
        }
        
        DispatchQueue.main.async {
            self.navigationController!.popToRootViewController(animated: true)
            if !self.navigationController!.isViewLoaded || self.navigationController!.view.window == nil {
                self.window?.rootViewController!.present(self.navigationController!,
                                                        animated: true,
                                                        completion: nil)
            }
        }
        return self.signInViewController!
    }
}

extension AppDelegate: AWSCognitoIdentityRememberDevice {

    
    func getRememberDevice(_ rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>) {
        self.rememberDeviceCompletionSource = rememberDeviceCompletionSource
        DispatchQueue.main.async {
            // dismiss the view controller being present before asking to remember device
            self.window?.rootViewController!.presentedViewController?.dismiss(animated: true, completion: nil)
            let alertController = UIAlertController(title: "Remember Device",
                                                    message: "Do you want to remember this device?.",
                                                    preferredStyle: .actionSheet)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.rememberDeviceCompletionSource?.set(result: true)
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
                self.rememberDeviceCompletionSource?.set(result: false)
            })
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                DispatchQueue.main.async {
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

}



//commited changes
