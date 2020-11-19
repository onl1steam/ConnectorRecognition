//
//  BlankInfoPlaceholder.swift
//  ConnectorRecognition
//
//  Created by Рыжков Артем on 19.11.2020.
//

import UIKit

class BlankInfoPlaceholder: UIView {
    
    let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder_text")
        return imageView
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет данных. Выберите изображение из галереи или сделайте фото."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGray
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(placeholderImageView)
        addSubview(placeholderLabel)
        setupLayout()
    }
    
    private func setupLayout() {
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 100),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50)
        ])
    }
}
