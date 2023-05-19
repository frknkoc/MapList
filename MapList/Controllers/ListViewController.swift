import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var nameArr = [String]()
    var idArr = [UUID]()
    
    var selectedLocName = ""
    var selectedLocId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("addedNewLocation"), object: nil)
    }
    
    @objc func getData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        
        do  {
            let sonuclar = try context.fetch(request)
            if sonuclar.count > 0 {
                nameArr.removeAll(keepingCapacity: false)
                idArr.removeAll(keepingCapacity: false)
                for sonuc in sonuclar as! [NSManagedObject]{
                    if let name = sonuc.value(forKey: "name") as? String {
                        nameArr.append(name)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idArr.append(id)
                    }
                }
                tableView.reloadData()
            }
        } catch {
            
        }
    }
    
    @IBAction func addLocation(_ sender: Any) {
        performSegue(withIdentifier: "toAddMapVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArr[indexPath.row].capitalized
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLocName = nameArr[indexPath.row]
        selectedLocId = idArr[indexPath.row]
        performSegue(withIdentifier: "toAddedLocationVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddedLocationVC" {
            let destinationVC = segue.destination as! AddedLocationViewController
            destinationVC.selectedName = selectedLocName
            destinationVC.selectedId = selectedLocId
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
            let uuidString = idArr[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0{
                    for sonuc in sonuclar as! [NSManagedObject] {
                        if let id = sonuc.value(forKey: "id") as? UUID{
                            if id == idArr[indexPath.row] {
                                context.delete(sonuc)
                                nameArr.remove(at: indexPath.row)
                                idArr.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do{
                                    try context.save()
                                } catch{
                                    
                                }
                                break
                            }
                        }
                    }
                }
                      
            } catch {
                print("Hata")
            }
        }
    }
}
