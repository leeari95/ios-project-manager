import UIKit

class ProjectCell: UITableViewCell {
    static let nibName = "ProjectCell"
    static let identifier = "projectCell"
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    func configure(_ project: Project) {
        titleLabel.text = project.title == "" ? "New Project" : project.title
        descriptionLabel.text = project.description == "" ? "No additional text" : project.description
        dateLabel.text = Date.formattedString(project.date)
        changedDateColor(project.date)
    }
    
    private func changedDateColor(_ date: Date) {
        dateLabel.textColor = date.isPastDeadline ? .systemRed : .black
    }
}
