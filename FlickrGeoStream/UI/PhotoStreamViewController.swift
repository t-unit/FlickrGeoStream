//
//  ViewController.swift
//  FlickrGeoStream
//
//  Created by Tobias Ottenweller on 25.07.17.
//  Copyright © 2017 Tobias Ottenweller. All rights reserved.
//

import UIKit

class PhotoStreamViewController: UIViewController {
    
    var viewModel = PhotoStreamViewModel() {
        didSet {
            observers = []
        }
    }

    @IBOutlet
    weak var startStopButton: UIBarButtonItem!

    @IBOutlet
    weak var tableView: UITableView!
    
    private var observers: [NSKeyValueObservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let runningObserver = viewModel.observe(\.isRunning) { [weak self] _, _ in
            self?.updateButton()
        }
        observers.append(runningObserver)
        
        let imageObserver = viewModel.observe(\.images) { [weak tableView] _, _ in
            tableView?.reloadData()
        }
        observers.append(imageObserver)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButton()
    }

    @IBAction
    func startStopButtonTouchUpInside(_ sender: Any) {
        viewModel.toggleRunning()
    }
    
    private func updateButton() {
        startStopButton?.title = viewModel.isRunning ? "Stop" : "Start"
    }
}

extension PhotoStreamViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeued = tableView.dequeueReusableCell(withIdentifier: "photo", for: indexPath)

        if let cell = dequeued as? PhotoStreamTableViewCell {
            cell.photoImageView.image = viewModel.images[indexPath.row]
        }

        return dequeued
    }
}

