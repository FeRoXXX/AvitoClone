//
//  UniversalCellDetailsViewController+extension.swift
//  NewProject
//
//  Created by Александр Федоткин on 23.01.2024.
//

import UIKit
import SDWebImage

//MARK: - get data from firebase
extension UniversalCellDetailsViewController {
    func getPostFromFirebase() {
        loadingIndicator.startAnimating()
        guard let uuid = uuid else {
            GlobalFunctions.alert(vc: self, title: "Ошибка", message: "Произошла ошибка попробуйте позднее")
            return
        }
        Task {
            do {
                try await post = ReceivedCurrentPost(uuidCurrentPost: uuid)
                guard let post = post,
                      let currentPost = post.currentPost,
                      let name = currentPost.name,
                      let price = currentPost.price,
                      let information = currentPost.information,
                      let city = currentPost.address,
                      let date = currentPost.date,
                      let image = currentPost.image else { return }
                publicationName.text = name
                publicationPrice.text = price
                aboutPublication.text = information
                self.city.text = city
                dateLabel.text = date
                for image in image {
                    imageArray.append(image)
                }
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    guard strongSelf.imageArray.count > 0 else { return }
                    SDWebImageManager.shared.loadImage(with: URL(string: strongSelf.imageArray.first!), options: .lowPriority, progress: .none) { image, _, error, _, _, _ in
                        if let image = image {
                            self?.imageView.image = self?.resizeImageToFullHD(image)
                        }
                    }
                }
                loadingIndicator.stopAnimating()
            } catch {
                print(error)
                loadingIndicator.stopAnimating()
            }
        }
    }
    
    func resizeImageToFullHD(_ image: UIImage) -> UIImage? {
        let targetSize = CGSize(width: 640, height: 480)
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
            SDImageCache.shared.clearMemory()
        }
    }
}

//MARK: - setup gesture for scrolling image
extension UniversalCellDetailsViewController {
    func setupGesture() {
        imageView.isUserInteractionEnabled = true
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGestureRight.direction = .right
        swipeGestureLeft.direction = .left
        imageView.addGestureRecognizer(swipeGestureLeft)
        imageView.addGestureRecognizer(swipeGestureRight)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            indexImage = (indexImage + 1) % imageArray.count
        }
        if gesture.direction == .right {
            indexImage = (indexImage - 1 + imageArray.count) % imageArray.count
        }
        
        updateImage()
    }
    
    func updateImage() {
        guard imageArray.count != 0 else { return }
        UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                guard strongSelf.imageArray.count > 0 else { return }
                SDWebImageManager.shared.loadImage(with: URL(string: strongSelf.imageArray[strongSelf.indexImage]), options: .lowPriority, progress: .none) { image, _, error, _, _, _ in
                    if let image = image {
                        self?.imageView.image = self?.resizeImageToFullHD(image)
                    }
                }
            }
        }, completion: nil)
    }
}

//MARK: - setup topBar
extension UniversalCellDetailsViewController {

    func setupTopBar() {
        topBar.backButtonTapped = { [weak self] in
            guard let self = self else {
                return
            }
            self.handleButtonTapped()
        }
        if buttonFlag != nil, buttonFlag! {
            topBar.firstButtonTapped = { [weak self] in
                guard let self = self else {
                    return
                }
                self.handleCorrectButtonTapped()
            }
            topBar.secondButtonTapped = { [weak self] in
                guard let self = self else {
                    return
                }
                self.handleDeleteButtonTapped()
            }
            topBar.firstButton.setImage(UIImage(systemName: "square.and.pencil.circle"), for: .normal)
            topBar.secondButton.setImage(UIImage(systemName: "trash"), for: .normal)
        } else {
            topBar.firstButton.isHidden = true
            topBar.secondButton.isHidden = true
        }
        topBar.topBarText.text = "Просмотр объявления"
    }
    
    private func handleCorrectButtonTapped() {
        let productsViewController = ProductsViewController()
        productsViewController.universalCellDetailsViewController = self
        productsViewController.uuid = self.uuid
        hidesBottomBarWhenPushed = true
        if let navigationController = navigationController {
            navigationController.pushViewController(productsViewController, animated: true)
        }
    }
    
    private func handleDeleteButtonTapped() {
        Task {
            do {
                guard let post = post else { return }
                try await post.deletePost()
                if let navigationController = navigationController {
                    self.scrollAndCollectionVC?.loadData()
                    navigationController.popViewController(animated: true)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func handleButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}
