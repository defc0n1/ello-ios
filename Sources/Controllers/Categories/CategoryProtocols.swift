////
///  CategoryProtocols.swift
//

public protocol CategoryScreenProtocol: StreamableScreenProtocol {
    var topInsetView: UIView { get }
    var categoryCardsVisible: Bool { get }
    func setCategoriesInfo(categoriesInfo: [CategoryCardListView.CategoryInfo], animated: Bool, completion: ElloEmptyCompletion)
    func animateCategoriesList(navBarVisible navBarVisible: Bool)
    func scrollToCategoryIndex(index: Int)
    func selectCategoryIndex(index: Int)
}

public protocol CategoryScreenDelegate: class {
    func categorySelected(index: Int)
}
