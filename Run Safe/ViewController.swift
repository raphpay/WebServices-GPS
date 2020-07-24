//
//  ViewController.swift
//  Triple Connexion Screens
//
//  Created by Raphaël Payet on 03/03/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

//TODO : Add observer to Keyboard
//TODO : Add Tap Gesture to Hide Keyboard
import UIKit

class ViewController: UIViewController {

    //MARK: - Objects
    var scrollView              : UIScrollView!
    var containerView           : UIView!
    
    var runnerLabel             : RSTitleLabel!
    var fanLabel                : RSTitleLabel!
    var serverLabel             : RSTitleLabel!
    
    var idTextField             : RSTextField!
    var otherTextField          : RSTextField!
    var finishButton            : RSButton!
    
    var testTextField : UITextField!
    var pageControl             : UIPageControl!
            
    var subviews                : [UIView]!
    var labels                  : [UIView]!
            
    //MARK: - Properties
    
    let padding                 : CGFloat = 20
    lazy var contentViewSize    : CGSize = CGSize(width: self.view.frame.width * 3, height: view.frame.height)
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        handleKeyboardShow()
    }


    //MARK: - Override Methods
    fileprivate func setupUI() {
        createSubviews()
        constraintSubviews()
        configureScrollView()
        configurePageControl()
    }
    
    fileprivate func handleKeyboardShow() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardMovement(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardMovement(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Helper Methods
    
    private func createSubviews() {
        runnerLabel     = RSTitleLabel(text: "Coureur")
        fanLabel        = RSTitleLabel(text: "Fan")
        serverLabel     = RSTitleLabel(text: "Serveur")
        
        idTextField     = RSTextField(placeholder: "Identifiant")
        otherTextField  = RSTextField(placeholder: "Code Course")
        finishButton    = RSButton(backgroundColor: .systemBlue, title: "Terminer")
        
        scrollView      = UIScrollView()
        pageControl     = UIPageControl()
        
        labels = [runnerLabel, fanLabel, serverLabel]
        for label in labels {
            scrollView.addSubview(label)
        }
        let xCoordinate1 = (view.frame.midX - 100)
        runnerLabel.frame = CGRect(x: xCoordinate1, y: view.frame.midY, width: 200, height: 30)
        
        let xCoordinate2 = (view.frame.midX - 100) + view.frame.width
        fanLabel.frame = CGRect(x: xCoordinate2, y: view.frame.midY, width: 200, height: 30)
        
        let xCoordinate3 = (view.frame.midX - 100) + view.frame.width * CGFloat(2)
        serverLabel.frame = CGRect(x: xCoordinate3, y: view.frame.midY, width: 200, height: 30)
        
        
    }
    private func constraintSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(pageControl)
        scrollView.addSubview(idTextField)
        scrollView.addSubview(otherTextField)
        scrollView.addSubview(finishButton)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        idTextField.translatesAutoresizingMaskIntoConstraints = false
        otherTextField.translatesAutoresizingMaskIntoConstraints = false
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.widthAnchor.constraint(equalToConstant: 50),
            pageControl.heightAnchor.constraint(equalToConstant: 50),
            
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            finishButton.heightAnchor.constraint(equalToConstant: 44),
            
            otherTextField.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -padding),
            otherTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            otherTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            otherTextField.heightAnchor.constraint(equalToConstant: 50),
            
            idTextField.bottomAnchor.constraint(equalTo: otherTextField.topAnchor, constant: -padding),
            idTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            idTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            idTextField.heightAnchor.constraint(equalToConstant: 50),
            

        ])
    }
    private func configureScrollView() {
        scrollView.contentSize      = CGSize(width: view.frame.width * 3, height: view.frame.height)
        scrollView.isScrollEnabled  = true
        scrollView.isPagingEnabled  = true
        scrollView.delegate         = self
        scrollView.backgroundColor  = .red
    }
    private func configurePageControl() {
        pageControl.numberOfPages   = 3
        pageControl.tintColor       = .systemGray
        pageControl.currentPageIndicatorTintColor = .blue
    }
    
    //MARK: - Actions
    
    @objc func keyboardMovement(_ notification : Notification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let show = (notification.name == UIResponder.keyboardWillShowNotification)
          ? true
          : false
        
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
    }
}


//MARK: - Extension
extension ConnexionVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        pageControl.currentPage = Int(scrollView.contentOffset.x / pageWidth)
        
    }
}
