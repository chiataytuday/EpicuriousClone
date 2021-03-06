//
//  RecipeDescriptionViewController.swift
//  EpicuriousClone
//
//  Created by Tringapps on 30/08/19.
//  Copyright © 2019 Tringapps. All rights reserved.
//

import UIKit

class NewestRecipeDescriptionViewController: UIViewController {
    @IBOutlet weak var recipeDescriptionTableView: UITableView!
    let ingredientsSegue:String = "ingredientsPageSegueIdentifier"
    lazy var navigationBarSaveButton: UIButton = {
        let imageToSet:UIImage = #imageLiteral(resourceName: "Add_Icon");
        let textToSet:String = "Save";
        let saveButton = UIButton(type: .system);
        saveButton.setImage(imageToSet, for: .normal);
        saveButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34);
        saveButton.contentMode = UIButton.ContentMode.scaleAspectFit;
        saveButton.setTitle(textToSet, for: .normal);
        saveButton.tintColor = UIColor.red;
        return saveButton;
    }()

    lazy var navigationBarShareButton: UIButton = {
        let imageToSet:UIImage = #imageLiteral(resourceName: "Share_Icon_Glyph");
        let textToSet:String = "Share";
        let shareButton = UIButton(type: .system);
        shareButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34);
        shareButton.setImage(imageToSet, for: .normal);
        shareButton.contentMode = UIButton.ContentMode.scaleAspectFit;
        shareButton.setTitle(textToSet, for: .normal);
        shareButton.tintColor = UIColor.red
        shareButton.addTarget(self, action: #selector(onClickShareButton(_:)), for: .touchUpInside)
        return shareButton;
    }()

    var headerCell:HeadingImageTableViewCell?
    var allRecipies:[NewestRecipiesDecodableDataModel] = []
    var selectedIndex:Int! = nil
    private let addToCartSegue:String = "addToShoppingListSegueIdentifier"
    private let reviewSegue:String = "ReviewsSegueIdentifier"
    private let unwindSegueIdentifier:String = "unwindToNewestRecipiesSegueIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        showNavigationController()
        setupDelegates()
        setScrollViewDelegate()
        print("Recipe Description View Loaded")
    }

    fileprivate func setupDelegates() {
        recipeDescriptionTableView.dataSource = self
        recipeDescriptionTableView.delegate = self
    }

    fileprivate func setUpButtons() {
        let floatingButton = IngredientsFloatingButton.getInstance()
        floatingButton.ingredientsList = allRecipies[selectedIndex].ingredients
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: navigationBarShareButton), UIBarButtonItem(customView: navigationBarSaveButton)]
    }

    fileprivate func setScrollViewDelegate() {
        let scrollView = view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
        scrollView.delegate = self
    }

    fileprivate func showNavigationController() {
        self.navigationController!.isNavigationBarHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        print("Recipe Description View Will Appear")
        super.viewWillAppear(animated)
        hideTabBarController()
        setUpButtons()
        IngredientsFloatingButton.getInstance().hideFloatingButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("Recipe Description View Will Disappear")
        super.viewWillDisappear(animated)
        showTabBarController()
        setClearNavigationBar()
    }

    fileprivate func hideTabBarController() {
        tabBarController?.tabBar.setTabBarVisibility(false)
    }

    fileprivate func showTabBarController() {
        tabBarController?.tabBar.setTabBarVisibility(true)
    }

    @IBAction func onClickBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onClickAddToShoppingListButton(_ sender: Any) {
        performSegue(withIdentifier: addToCartSegue, sender: self)
    }

    @IBAction func onClickShareButton(_ sender: Any) {
        let shareActivity = UIActivityViewController(activityItems: [self.allRecipies[selectedIndex].recipeName!], applicationActivities: nil)
        self.present(shareActivity, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addToCartViewController = segue.destination as? AddToCartViewController {
            addToCartViewController.allIngredients = allRecipies[selectedIndex].ingredients
        } else if let newestRecipeDescriptionViewController = segue.destination as? NewestRecipeDescriptionViewController {
            newestRecipeDescriptionViewController.allRecipies = self.allRecipies
            newestRecipeDescriptionViewController.selectedIndex = MoreRecipiesCollectionViewTableViewCell.selectedIndex
        } else if let ingredientsViewController = segue.destination as? IngredientsPageViewController{
            ingredientsViewController.ingredients = self.allRecipies[selectedIndex].ingredients
        }
    }

    deinit {
        hideFloatingButton()
        print("Recipe Description View Safe From Memory Leaks")
    }
}

extension NewestRecipeDescriptionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 2) {
            return allRecipies[selectedIndex].ingredients.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return getCellForDescriptionPage(forSection: indexPath.section, atIndex: indexPath.row)
    }

    fileprivate func getCellForDescriptionPage(forSection section:Int, atIndex row:Int) ->UITableViewCell {
        switch  section {
        case 0:
            let cell = recipeDescriptionTableView.dequeueReusableCell(withIdentifier: HeadingImageTableViewCell.reusableIdentity) as! HeadingImageTableViewCell
            cell.setValue(imageUrl: allRecipies[row].recipeImageUrl)
            headerCell = cell
            return cell
        case 1:
            let cell = recipeDescriptionTableView.dequeueReusableCell(withIdentifier: RecipeReviewTableViewCell.reusableIdentity) as! RecipeReviewTableViewCell
            cell.setValue(data: allRecipies[selectedIndex])
            return cell
        case 2:
            let cell = recipeDescriptionTableView.dequeueReusableCell(withIdentifier: IngredientInnerTableViewCell.reusableIdentity) as! IngredientInnerTableViewCell
            cell.setValues(ingredient: allRecipies[selectedIndex].ingredients[row])
            return cell
        case 3:
            let cell = recipeDescriptionTableView.dequeueReusableCell(withIdentifier: AddToCartButtonTableViewCell.reusableIdentity) as! AddToCartButtonTableViewCell
            cell.setValues(ingredientArray: allRecipies[selectedIndex].ingredients)
            return cell
        case 4:
            let cell = recipeDescriptionTableView.dequeueReusableCell(withIdentifier: PreparationTextTableViewCell.reusableIdentity) as! PreparationTextTableViewCell
            cell.setValue(preparation: allRecipies[selectedIndex].preparation)
            return cell
        case 5:
            let cell = recipeDescriptionTableView.dequeueReusableCell(withIdentifier: keywordCollectionViewTableViewCell.reusableIdentity) as! keywordCollectionViewTableViewCell
            cell.setValue(keywordArray: allRecipies[selectedIndex].keyWords)
            return cell
        case 6:
            let cell = recipeDescriptionTableView.dequeueReusableCell(withIdentifier: MoreRecipiesCollectionViewTableViewCell.reusableIdentity) as! MoreRecipiesCollectionViewTableViewCell
            cell.setValues(recipies: allRecipies, parent: self)
            return cell
        default:
            print("Internal Error In CollectionView")
            let cell = recipeDescriptionTableView.dequeueReusableCell(withIdentifier: HeadingImageTableViewCell.reusableIdentity) as! HeadingImageTableViewCell
            return cell
        }
    }

    fileprivate func checkIfProcedureCellIsVisible() {
        guard let visibleIndices = recipeDescriptionTableView.indexPathsForVisibleRows else {return}
        for index in visibleIndices {
            if(index.section == 4 ) {
                showFloatingButton()
                return
            }
        }
        hideFloatingButton()
        return
    }

    fileprivate func showFloatingButton() {
        let floatingButton = IngredientsFloatingButton.getInstance()
        if(floatingButton.isOverScreen) {return}
        floatingButton.slideInFloatinButton()
    }

    fileprivate func hideFloatingButton() {
        let floatingButton = IngredientsFloatingButton.getInstance()
        floatingButton.slideOutFloatingButton()
    }
}

extension NewestRecipeDescriptionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 200
        case 1:
            return 250
        case 2:
            return 50
        case 3:
            return 100
        case 4:
            return 550
        case 5:
            return 75
        case 6:
            return 350
        default:
            return 250
        }
    }
}

extension NewestRecipeDescriptionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkIfProcedureCellIsVisible()
        let imageHeight:CGFloat = 200-54
        var offset = scrollView.contentOffset.y / imageHeight
        if  offset > 1{
            offset = 1
            UIView.animate(withDuration: 0.1) {
                [weak self] in
                self?.setOpaqueNavigationBar()
                self?.showNavigationBarButtons()
            }
        }
        else {
            UIView.animate(withDuration: 0.1) {
                [weak self] in
                self?.hideNavigationBarButttons()
                self?.setClearNavigationBar()
            }
        }
    }

    fileprivate func setClearNavigationBar() {
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.barStyle = .black
        UIApplication.shared.statusBarView.backgroundColor = UIColor.clear
    }

    fileprivate func setOpaqueNavigationBar() {
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barStyle = .default
        UIApplication.shared.statusBarView.backgroundColor = UIColor.white
    }

    fileprivate func hideNavigationBarButttons() {
        let previousHiddenState = navigationBarShareButton.isHidden
        if(previousHiddenState) {
            navigationBarSaveButton.slideIn(horizontally: -10)
            navigationBarShareButton.slideIn(horizontally: -10)
        }
        navigationBarShareButton.isHidden = true
        navigationBarSaveButton.isHidden = true
    }

    fileprivate func showNavigationBarButtons() {
        let previousHiddenState = navigationBarShareButton.isHidden
        navigationBarShareButton.isHidden = false
        navigationBarSaveButton.isHidden = false
        if(previousHiddenState) {
            navigationBarSaveButton.slideIn(horizontally: 10)
            navigationBarShareButton.slideIn(horizontally: 10)
        }
    }
}

