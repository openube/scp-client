//
//  DetailViewController.swift
//  SCP
//
//  Created by LD on 4/6/18.
//  Copyright © 2018 LD. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var leftTable: UITableView?
    @IBOutlet var rightTable: UITableView?

    var leftServer: SSHServerTableViewController? = nil
    var rightServer: SSHServerTableViewController? = nil

    func configureView() {

        if let viewState = UserDefaults.standard.object(forKey: detailItemUUID + "_selected_view") as? Int {
            DispatchQueue.main.async {
                if (viewState == 1) {
                    self.showLeft()
                } else if (viewState == 2) {
                    self.showBoth()
                } else if (viewState == 3) {
                    self.showRigh()
                }
            }
        }

        if let detail = detailItem {
            do {
                let jsonDecoder = JSONDecoder()
                let server = try jsonDecoder.decode(SSHServer.self, from: detail.data(using: .utf8)!)

                self.title = server.name

                leftServer = SSHServerTableViewController.init(nibName: nil, bundle: nil)
                rightServer = SSHServerTableViewController.init(nibName: nil, bundle: nil)

                leftServer?.isLeft = true
                rightServer?.isLeft = false

                leftServer?.tableView = leftTable
                rightServer?.tableView = rightTable

                leftServer?.SSHServer = server
                rightServer?.SSHServer = server

                leftServer?.presenter = self.presenter
                rightServer?.presenter = self.presenter

                leftServer?.sideListener = rightServer?.sideReceived
                rightServer?.sideListener = leftServer?.sideReceived

                leftServer?.executionListener = rightServer?.handleAfterExecution
                rightServer?.executionListener = leftServer?.handleAfterExecution

                leftServer?.serverUUID = detailItemUUID
                rightServer?.serverUUID = detailItemUUID

                leftServer?.start();
                rightServer?.start();

            } catch let error {
                print("error: \(error)")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        leftServer?.stop()
        rightServer?.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global(qos: .userInteractive).async {
            self.configureView()
        }

        for barButton in self.navigationItem.rightBarButtonItems! {
            if (barButton.tag == 1) {
                barButton.setIcon(icon: .googleMaterialDesign(.borderLeft), iconSize: 30, color: .blue)
            } else if (barButton.tag == 2) {
                barButton.setIcon(icon: .googleMaterialDesign(.borderVertical), iconSize: 30, color: .blue)
            } else if (barButton.tag == 3) {
                barButton.setIcon(icon: .googleMaterialDesign(.borderRight), iconSize: 30, color: .blue)
            }
        }

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissOnDone))
    }

    @objc func dismissOnDone() {
        self.dismiss(animated: true, completion: nil)
    }

    private func presenter(_ viewControllerToPresent: UIAlertController, animated flag: Bool, completion: (() -> Void)? = nil) {
        self.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showLeft(sender: UIBarButtonItem? = nil) {
        leftTable?.isHidden = false
        rightTable?.isHidden = true

        UserDefaults.standard.set(1, forKey: detailItemUUID + "_selected_view")
    }

    @IBAction func showBoth(sender: UIBarButtonItem? = nil) {
        leftTable?.isHidden = false
        rightTable?.isHidden = false
        UserDefaults.standard.set(2, forKey: detailItemUUID + "_selected_view")
    }

    @IBAction func showRigh(sender: UIBarButtonItem? = nil) {
        leftTable?.isHidden = true
        rightTable?.isHidden = false
        UserDefaults.standard.set(3, forKey: detailItemUUID + "_selected_view")
    }

    var detailItem: String?
    var detailItemUUID: String = ""


}

