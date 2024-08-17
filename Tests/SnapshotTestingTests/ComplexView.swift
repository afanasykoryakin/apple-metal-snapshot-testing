//
// ComplexView.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 11.09.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License
//

import UIKit

class ComplexView: UIView {
    private let circleView = UIView()
    private let gradientLayer = CAGradientLayer() // Сохраняем ссылку на градиент
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .white
        
        // Настраиваем градиентный слой
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.layer.insertSublayer(gradientLayer, at: 0) // Вставляем в начало слоя
        
        // Настраиваем круглый UIView
        circleView.backgroundColor = .yellow
        circleView.layer.cornerRadius = 50 // изначально, но позже будет пересчитан
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOpacity = 0.5
        circleView.layer.shadowOffset = CGSize(width: 4, height: 4)
        circleView.layer.shadowRadius = 10
        self.addSubview(circleView)
        
        // Отключаем autoresizing mask и включаем auto layout
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем auto layout ограничения для динамической позиции и размера
        NSLayoutConstraint.activate([
            // Центрирование круга по горизонтали и вертикали
            circleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            // Задаем ширину и высоту круга пропорционально ширине родительского представления
            circleView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor)
        ])
        
        // Добавляем UILabel
        let label = UILabel()
        label.text = "Complex UI"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        // Добавляем UIImageView с рамкой
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .orange
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Добавляем кнопку
        let button = UIButton(type: .system)
        button.setTitle("Tap me", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 150),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем градиент при изменении размеров
        gradientLayer.frame = self.bounds
        
        // Обновляем cornerRadius у круга на основании текущей ширины
        circleView.layer.cornerRadius = circleView.frame.width / 2
    }
}
