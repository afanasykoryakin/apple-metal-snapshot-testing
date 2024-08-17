//
// InteractiveView.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 11.09.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License
//

import UIKit

class InteractiveView: UIView {
    private let circleView = UIView()
    private let actionButton = UIButton(type: .system)
    private let cycleAnimationButton = UIButton(type: .system)
    
    private var isChanged = false // Флаг для отслеживания состояния
    private var isCycleAnimationRunning = false // Флаг для отслеживания цикличной анимации
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Устанавливаем голубой фон
        self.backgroundColor = .systemBlue
        
        // Настраиваем круглый UIView
        circleView.backgroundColor = .white
        circleView.layer.cornerRadius = 50 // Начальный радиус
        self.addSubview(circleView)
        
        // Отключаем autoresizing mask и включаем auto layout
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем auto layout ограничения для динамической позиции и размера круга
        NSLayoutConstraint.activate([
            // Центрирование круга по горизонтали и вертикали
            circleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            // Начальный фиксированный размер круга
            circleView.widthAnchor.constraint(equalToConstant: 100),
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor)
        ])
        
        // Настраиваем основную кнопку
        actionButton.setTitle("Change!", for: .normal)
        actionButton.backgroundColor = .systemGreen
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.layer.cornerRadius = 10
        self.addSubview(actionButton)
        
        // Отключаем autoresizing mask для кнопки и включаем auto layout
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем auto layout ограничения для кнопки
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 20),
            actionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 150),
            actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Добавляем действие для кнопки
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Настраиваем новую кнопку для цикличной анимации
        cycleAnimationButton.setTitle("Cycle Animation", for: .normal)
        cycleAnimationButton.backgroundColor = .systemOrange
        cycleAnimationButton.setTitleColor(.white, for: .normal)
        cycleAnimationButton.layer.cornerRadius = 10
        self.addSubview(cycleAnimationButton)
        
        // Отключаем autoresizing mask для второй кнопки и включаем auto layout
        cycleAnimationButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем auto layout ограничения для второй кнопки
        NSLayoutConstraint.activate([
            cycleAnimationButton.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 20),
            cycleAnimationButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cycleAnimationButton.widthAnchor.constraint(equalToConstant: 200),
            cycleAnimationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Добавляем действие для новой кнопки
        cycleAnimationButton.addTarget(self, action: #selector(startCycleAnimation), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        // Переключаем состояние флага
        isChanged.toggle()
        
        // Анимируем изменения
        UIView.animate(withDuration: 0.3) {
            if self.isChanged {
                // Изменение состояния: перекрашиваем круг и увеличиваем его
                self.circleView.backgroundColor = .systemRed
                self.circleView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                
                // Меняем фон родительского UIView
                self.backgroundColor = .systemYellow
            } else {
                // Возвращаем все обратно
                self.circleView.backgroundColor = .white
                self.circleView.transform = CGAffineTransform.identity
                
                // Восстанавливаем исходный фон
                self.backgroundColor = .systemBlue
            }
        }
    }

    @objc func startCycleAnimation() {
        // Переключаем состояние цикличной анимации
        isCycleAnimationRunning.toggle()

        if isCycleAnimationRunning {
            // Запускаем цикличную анимацию с повтором и возвратом
            UIView.animate(withDuration: 5.0,
                           delay: 0.0,
                           options: [.repeat, .autoreverse],
                           animations: {
                self.circleView.transform = CGAffineTransform(scaleX: 3, y: 3)
            }, completion: nil)
        } else {
            // Останавливаем анимацию
            self.circleView.layer.removeAllAnimations()
            
            // Возвращаем круг в исходное состояние
            UIView.animate(withDuration: 5) {
                self.circleView.transform = CGAffineTransform.identity
            }
        }
    }
}

