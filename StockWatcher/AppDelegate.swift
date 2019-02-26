import UIKit
import CoreData
import AWSCognitoIdentityProvider

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,  AWSCognitoIdentityInteractiveAuthenticationDelegate  {
  
  var window: UIWindow?
  var signInViewController: LoginViewController?
  var mfaViewController: ConfirmViewController?
  var navigationController: UINavigationController?
  var storyboard: UIStoryboard?
  var rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
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
    
    
  /** AWS Cognito Authentication */
    //MARK:- Check on the view controllers management in ios swift
    //TODO:- Do this in laboartory before implementing
    
  func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
    
    print("message: startPasswordAuthentication() ->")
        if self.navigationController == nil {
            self.navigationController = self.storyboard?.instantiateViewController(withIdentifier: "signinController") as? UINavigationController
            print("navigation controller \(self.navigationController) count: \(self.navigationController?.viewControllers.count)")
        }

        if self.signInViewController == nil {
            self.signInViewController = self.navigationController?.viewControllers[0] as? LoginViewController
            print("Signin view controller \(self.signInViewController)")
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
    
  func startMultiFactorAuthentication() -> AWSCognitoIdentityMultiFactorAuthentication {
        if (self.mfaViewController == nil) {
            self.mfaViewController = ConfirmViewController()
            self.mfaViewController?.modalPresentationStyle = .popover
        }
        DispatchQueue.main.async {
            if (!self.mfaViewController!.isViewLoaded
                || self.mfaViewController!.view.window == nil) {
                //display mfa as popover on current view controller
                let viewController = self.window?.rootViewController!
                viewController?.present(self.mfaViewController!,
                                        animated: true,
                                        completion: nil)
                
                // configure popover vc
                let presentationController = self.mfaViewController!.popoverPresentationController
                presentationController?.permittedArrowDirections = UIPopoverArrowDirection.left
                presentationController?.sourceView = viewController!.view
                presentationController?.sourceRect = viewController!.view.bounds
            }
        }
        return self.mfaViewController!
  }
    
  func startRememberDevice() -> AWSCognitoIdentityRememberDevice {
        return self
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
    
  func saveContext (){
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

