//
//  RecognitionInfoViewController.swift
//  ConnectorRecognition
//
//  Created by Рыжков Артем on 18.11.2020.
//

import UIKit

class RecognitionInfoViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var blankInfoPlaceholder: BlankInfoPlaceholder!
    
    var recognitionData: [RecognitionModel] = []
    
    lazy var recognitionTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        
        recognitionTableView.register(RecognitionInfoTableViewCell.self,
                                      forCellReuseIdentifier: RecognitionInfoTableViewCell.reuseIdentifier)
        recognitionTableView.delegate = self
        recognitionTableView.dataSource = self
        view.insertSubview(recognitionTableView, belowSubview: blankInfoPlaceholder)
        setupTableViewLayout()
    }
    
    func updateInfo(_ info: [RecognitionModel]) {
        blankInfoPlaceholder.alpha = 0
        recognitionData = info
        recognitionTableView.reloadData()
    }
    
    func clearInfo() {
        UIView.animate(withDuration: 1) {
            self.blankInfoPlaceholder.alpha = 1
        }
        recognitionData = []
        recognitionTableView.reloadData()
    }
    
    private func setupTableViewLayout() {
        recognitionTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recognitionTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            recognitionTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recognitionTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recognitionTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20)
        ])
    }
}

extension RecognitionInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Core ML"
        case 1:
            return "Watson ML"
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        recognitionData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recognitionData[safeIndex: 0]?.results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecognitionInfoTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? RecognitionInfoTableViewCell else {
            return UITableViewCell()
        }
        guard let recognitionInfo = recognitionData[safeIndex: indexPath.section]?.results else {
            return UITableViewCell()
        }
        cell.variantLabel.text = recognitionInfo[indexPath.row].variant
        cell.confidenceLabel.text = "Уверенность: " + recognitionInfo[indexPath.row].confidence + "%"
        return cell
    }
}
