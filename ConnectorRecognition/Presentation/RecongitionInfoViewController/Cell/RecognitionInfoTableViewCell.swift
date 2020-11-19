//
//  RecognitionInfoTableViewCell.swift
//  ConnectorRecognition
//
//  Created by Рыжков Артем on 18.11.2020.
//

import UIKit

class RecognitionInfoTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "RecognitionInfoTableViewCell"
    
    var variantLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var confidenceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(variantLabel)
        addSubview(confidenceLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupConstraints() {
        variantLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            variantLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            variantLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
        
        confidenceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confidenceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            confidenceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}
