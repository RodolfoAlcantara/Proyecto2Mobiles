//
//  HomeViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController {
    @IBOutlet weak var comentariosTableView: UITableView!
    let username: String = UserDefaults.standard.string(forKey: "name") ?? ""
    var databaseRef = FIRDatabase.database().reference()
    var comentarios: [[String: String]] = [[String: String]](){
        didSet {
            self.comentariosTableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Comentarios"
        self.comentarios.removeAll()
        databaseRef.child("users/" + self.username + "/Comentarios/").observe(.childAdded) { (data) in
            self.saveData(data: data)
        }
        databaseRef.child("users/" + self.username + "/Comentarios/").observe(.childChanged) { (data) in
            self.saveData(data: data)
        }
        databaseRef.child("users/" + self.username + "/Comentarios/").observe(.childRemoved) { (data) in
            self.comentariosTableView.reloadData()
        }
    }
    @IBAction func addComment(_ sender: Any) {
        self.alertAddComment()
    }
    public func saveData(data: FIRDataSnapshot){
        var comentario: [String: String] = (data.value as? [String: String])!
        comentario["key"] = data.key
        self.comentarios.append(comentario)
    }
    public func alertAddComment() {
        let alert = UIAlertController(title: "Agregar comentario", message: "Comentario para blog de la flor", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Escribe algo aquí ..."
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Enviar", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            guard let texto = textField?.text else { return }
            self.sendComment(comentario: texto)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    public func sendComment(comentario: String){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let myStringafd = formatter.string(from: yourDate!)
        let number = Int.random(in: 0 ..< 999)
        self.databaseRef.child("users/" + self.username + "/Comentarios/").child(self.username + "\(number)").setValue(["Comentario": comentario, "Fecha": myStringafd])
    }
    @IBAction func logOutAction(sender: AnyObject) {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Navigation")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    public func makeAlertEdit(comentarioID: String, indexComentario: Int) {
        let alert = UIAlertController(title: "Editar comentario", message: "Comentario para blog de la flor", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Escribe algo aquí ..."
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Enviar", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            guard let texto = textField?.text else { return }
            self.updateComment(comentario: texto, comentarioID: comentarioID, indexComentario: indexComentario)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    public func updateComment(comentario: String, comentarioID: String, indexComentario: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let myStringafd = formatter.string(from: yourDate!)
        let number = Int.random(in: 0 ..< 999)
        self.databaseRef.child("users/" + self.username + "/Comentarios/").child(comentarioID).setValue(["Comentario": comentario, "Fecha": myStringafd])
        self.comentarios.remove(at: indexComentario)
    }
    public func actionSheetComentario(indexpath: Int?) {
        let alert = UIAlertController(title: "Acciones", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Editar", style: .default, handler: { [weak alert] (_) in
            guard let index = indexpath else { return }
            guard let idComentario = self.comentarios[index]["key"] else { return }
            self.makeAlertEdit(comentarioID: idComentario, indexComentario: index)
        }))
        alert.addAction(UIAlertAction(title: "Eliminar", style: .default, handler: { [weak alert] (_) in
            guard let index = indexpath else { return }
            guard let idComentario = self.comentarios[index]["key"] else { return }
            FIRDatabase.database().reference(withPath: "users/" + self.username + "/Comentarios/" + idComentario).removeValue()
            guard let indexBorrar = self.comentarios.index(of: self.comentarios[index]) as? Int else { return }
            self.comentarios.remove(at: indexBorrar)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comentarios.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(integerLiteral: 120)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = comentariosTableView.dequeueReusableCell(withIdentifier: "ComentarioTableViewCell", for: indexPath) as? ComentarioTableViewCell else { return UITableViewCell()}
        let data = self.comentarios[indexPath.row]
        cell.lblFecha.text = data["Fecha"]
        cell.textFieldComentario.text = data["Comentario"]
        cell.textFieldComentario.isUserInteractionEnabled = false
        cell.lblNombre.text = username
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.actionSheetComentario(indexpath: indexPath.row)
    }
}
