import Foundation

class Group : PFObject, PFSubclassing {
    
    override class func load() {
        
        self.registerSubclass()
        
    }
    
    class func parseClassName() -> String! {
        
        return "Group"
        
    }
    
}