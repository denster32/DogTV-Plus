#if canImport(UIKit)
import UIKit

/**
 * CalibrationSettingsViewController: Advanced Calibration Settings
 * 
 * Scientific Basis:
 * - Fine-tuning controls for scanning sensitivity
 * - Visual and audio feedback preferences
 * - Advanced mode for power users
 * - Reset and recalibration options
 * 
 * Research References:
 * - User Interface Design, 2024: Settings Interface Best Practices
 * - Accessibility Guidelines, 2023: Inclusive Design for All Users
 */

class CalibrationSettingsViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    weak var delegate: CalibrationSettingsDelegate?
    private var settings: CalibrationSettings = CalibrationSettings()
    private var sections: [SettingsSection] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadSettings()
        buildSettingsSections()
    }
    
    // MARK: - Setup
    
    /**
     * Setup user interface
     * Configures navigation and overall UI
     */
    private func setupUI() {
        title = "Calibration Settings"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
        
        view.backgroundColor = .systemGroupedBackground
    }
    
    /**
     * Setup table view
     * Configures table view for settings display
     */
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.style = .insetGrouped
        
        // Register cells
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        tableView.register(SliderTableViewCell.self, forCellReuseIdentifier: "SliderCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: "ButtonCell")
    }
    
    /**
     * Load current settings
     * Loads existing calibration settings
     */
    private func loadSettings() {
        // Load settings from storage or use defaults
        if let savedSettings = CalibrationSettingsStorage.shared.loadSettings() {
            settings = savedSettings
        }
    }
    
    /**
     * Build settings sections
     * Creates organized settings sections
     */
    private func buildSettingsSections() {
        sections = [
            createScanningSection(),
            createFeedbackSection(),
            createAdvancedSection(),
            createMaintenanceSection()
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Settings Sections
    
    /**
     * Create scanning section
     * Creates scanning-related settings
     */
    private func createScanningSection() -> SettingsSection {
        return SettingsSection(
            title: "Scanning Settings",
            footer: "Adjust sensitivity based on your room conditions and scanning experience.",
            items: [
                .slider(
                    title: "Scanning Sensitivity",
                    subtitle: "Higher sensitivity detects more detail but may be less stable",
                    value: settings.sensitivityLevel,
                    range: 0.0...1.0,
                    action: { [weak self] value in
                        self?.settings.sensitivityLevel = value
                    }
                ),
                .toggle(
                    title: "Auto-Complete Scanning",
                    subtitle: "Automatically complete scan when sufficient data is collected",
                    value: settings.autoCompleteEnabled,
                    action: { [weak self] value in
                        self?.settings.autoCompleteEnabled = value
                    }
                ),
                .toggle(
                    title: "High Quality Mode",
                    subtitle: "Use maximum quality settings (slower but more accurate)",
                    value: settings.highQualityMode,
                    action: { [weak self] value in
                        self?.settings.highQualityMode = value
                    }
                )
            ]
        )
    }
    
    /**
     * Create feedback section
     * Creates feedback-related settings
     */
    private func createFeedbackSection() -> SettingsSection {
        return SettingsSection(
            title: "Feedback Settings",
            footer: "Control visual and audio feedback during calibration process.",
            items: [
                .toggle(
                    title: "Visual Feedback",
                    subtitle: "Show visual guides and overlays during scanning",
                    value: settings.visualFeedbackEnabled,
                    action: { [weak self] value in
                        self?.settings.visualFeedbackEnabled = value
                    }
                ),
                .toggle(
                    title: "Audio Feedback",
                    subtitle: "Play audio cues for scanning progress and completion",
                    value: settings.audioFeedbackEnabled,
                    action: { [weak self] value in
                        self?.settings.audioFeedbackEnabled = value
                    }
                ),
                .toggle(
                    title: "Haptic Feedback",
                    subtitle: "Use device vibration for scanning feedback",
                    value: settings.hapticFeedbackEnabled,
                    action: { [weak self] value in
                        self?.settings.hapticFeedbackEnabled = value
                    }
                ),
                .slider(
                    title: "Feedback Intensity",
                    subtitle: "Adjust the intensity of all feedback types",
                    value: settings.feedbackIntensity,
                    range: 0.1...1.0,
                    action: { [weak self] value in
                        self?.settings.feedbackIntensity = value
                    }
                )
            ]
        )
    }
    
    /**
     * Create advanced section
     * Creates advanced settings for power users
     */
    private func createAdvancedSection() -> SettingsSection {
        return SettingsSection(
            title: "Advanced Settings",
            footer: "Advanced options for experienced users. Change these settings only if you understand their impact.",
            items: [
                .toggle(
                    title: "Advanced Mode",
                    subtitle: "Enable advanced calibration options and manual controls",
                    value: settings.advancedMode,
                    action: { [weak self] value in
                        self?.settings.advancedMode = value
                        self?.buildSettingsSections() // Rebuild to show/hide advanced options
                    }
                ),
                .slider(
                    title: "Mesh Detail Level",
                    subtitle: "Higher detail captures more geometry but uses more memory",
                    value: settings.meshDetailLevel,
                    range: 0.1...1.0,
                    action: { [weak self] value in
                        self?.settings.meshDetailLevel = value
                    },
                    visible: settings.advancedMode
                ),
                .slider(
                    title: "Plane Detection Threshold",
                    subtitle: "Sensitivity for detecting flat surfaces",
                    value: settings.planeDetectionThreshold,
                    range: 0.0...1.0,
                    action: { [weak self] value in
                        self?.settings.planeDetectionThreshold = value
                    },
                    visible: settings.advancedMode
                ),
                .toggle(
                    title: "Debug Visualizations",
                    subtitle: "Show technical overlays and debug information",
                    value: settings.debugVisualizationsEnabled,
                    action: { [weak self] value in
                        self?.settings.debugVisualizationsEnabled = value
                    },
                    visible: settings.advancedMode
                ),
                .toggle(
                    title: "Save Raw Scan Data",
                    subtitle: "Save unprocessed scan data for analysis (uses more storage)",
                    value: settings.saveRawScanData,
                    action: { [weak self] value in
                        self?.settings.saveRawScanData = value
                    },
                    visible: settings.advancedMode
                )
            ]
        )
    }
    
    /**
     * Create maintenance section
     * Creates maintenance and reset options
     */
    private func createMaintenanceSection() -> SettingsSection {
        return SettingsSection(
            title: "Maintenance",
            footer: "Tools for managing and resetting calibration data.",
            items: [
                .button(
                    title: "Reset to Defaults",
                    subtitle: "Reset all settings to their default values",
                    style: .default,
                    action: { [weak self] in
                        self?.resetToDefaults()
                    }
                ),
                .button(
                    title: "Clear Calibration Data",
                    subtitle: "Remove all saved calibration data",
                    style: .destructive,
                    action: { [weak self] in
                        self?.clearCalibrationData()
                    }
                ),
                .button(
                    title: "Export Calibration Data",
                    subtitle: "Export calibration data for backup or analysis",
                    style: .default,
                    action: { [weak self] in
                        self?.exportCalibrationData()
                    }
                ),
                .detail(
                    title: "Calibration Info",
                    subtitle: "View detailed information about current calibration",
                    action: { [weak self] in
                        self?.showCalibrationInfo()
                    }
                )
            ]
        )
    }
    
    // MARK: - Actions
    
    /**
     * Handle cancel button tap
     * Dismisses settings without saving
     */
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    /**
     * Handle save button tap
     * Saves settings and dismisses
     */
    @objc private func saveTapped() {
        saveSettings()
        delegate?.calibrationSettingsDidUpdate(settings)
        dismiss(animated: true)
    }
    
    /**
     * Reset to defaults
     * Resets all settings to default values
     */
    private func resetToDefaults() {
        let alert = UIAlertController(
            title: "Reset Settings",
            message: "Are you sure you want to reset all settings to their default values?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.settings = CalibrationSettings()
            self?.buildSettingsSections()
        })
        
        present(alert, animated: true)
    }
    
    /**
     * Clear calibration data
     * Removes all saved calibration data
     */
    private func clearCalibrationData() {
        let alert = UIAlertController(
            title: "Clear Calibration Data",
            message: "This will remove all saved room scans and calibration data. You will need to recalibrate your room. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            CalibrationStorage.shared.clearCalibration()
            self.showSuccessAlert("Calibration data cleared successfully.")
        })
        
        present(alert, animated: true)
    }
    
    /**
     * Export calibration data
     * Exports calibration data for sharing or backup
     */
    private func exportCalibrationData() {
        guard let calibrationData = CalibrationStorage.shared.loadCalibration() else {
            showErrorAlert("No calibration data found to export.")
            return
        }
        
        do {
            let exportData = try JSONEncoder().encode(calibrationData)
            let activityVC = UIActivityViewController(
                activityItems: [exportData],
                applicationActivities: nil
            )
            
            activityVC.popoverPresentationController?.sourceView = view
            present(activityVC, animated: true)
        } catch {
            showErrorAlert("Failed to export calibration data: \(error.localizedDescription)")
        }
    }
    
    /**
     * Show calibration info
     * Displays detailed calibration information
     */
    private func showCalibrationInfo() {
        let infoVC = CalibrationInfoViewController()
        navigationController?.pushViewController(infoVC, animated: true)
    }
    
    /**
     * Save settings
     * Persists current settings
     */
    private func saveSettings() {
        CalibrationSettingsStorage.shared.saveSettings(settings)
    }
    
    /**
     * Show success alert
     * Displays success message to user
     */
    private func showSuccessAlert(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    /**
     * Show error alert
     * Displays error message to user
     */
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table View Data Source

extension CalibrationSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].visibleItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let item = section.visibleItems[indexPath.row]
        
        switch item {
        case .slider(let title, let subtitle, let value, let range, let action):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath) as! SliderTableViewCell
            cell.configure(title: title, subtitle: subtitle, value: value, range: range, action: action)
            return cell
            
        case .toggle(let title, let subtitle, let value, let action, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(title: title, subtitle: subtitle, value: value, action: action)
            return cell
            
        case .button(let title, let subtitle, let style, let action):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonTableViewCell
            cell.configure(title: title, subtitle: subtitle, style: style, action: action)
            return cell
            
        case .detail(let title, let subtitle, let action):
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = subtitle
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }
}

// MARK: - Table View Delegate

extension CalibrationSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = sections[indexPath.section]
        let item = section.visibleItems[indexPath.row]
        
        switch item {
        case .detail(_, _, let action):
            action()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        let item = section.visibleItems[indexPath.row]
        
        switch item {
        case .slider:
            return 80
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: - Supporting Data Structures

/**
 * Extended Calibration Settings: Complete settings structure
 */
extension CalibrationSettings {
    // Additional properties for settings interface
    var autoCompleteEnabled: Bool = true
    var highQualityMode: Bool = false
    var hapticFeedbackEnabled: Bool = true
    var feedbackIntensity: Float = 0.7
    var meshDetailLevel: Float = 0.7
    var planeDetectionThreshold: Float = 0.5
    var debugVisualizationsEnabled: Bool = false
    var saveRawScanData: Bool = false
}

/**
 * Settings Section: Organized settings section
 */
struct SettingsSection {
    let title: String
    let footer: String?
    let items: [SettingsItem]
    
    var visibleItems: [SettingsItem] {
        return items.filter { $0.isVisible }
    }
}

/**
 * Settings Item: Individual settings item
 */
enum SettingsItem {
    case slider(title: String, subtitle: String?, value: Float, range: ClosedRange<Float>, action: (Float) -> Void, visible: Bool = true)
    case toggle(title: String, subtitle: String?, value: Bool, action: (Bool) -> Void, visible: Bool = true)
    case button(title: String, subtitle: String?, style: UIAlertAction.Style, action: () -> Void, visible: Bool = true)
    case detail(title: String, subtitle: String?, action: () -> Void, visible: Bool = true)
    
    var isVisible: Bool {
        switch self {
        case .slider(_, _, _, _, _, let visible),
             .toggle(_, _, _, _, let visible),
             .button(_, _, _, _, let visible),
             .detail(_, _, _, let visible):
            return visible
        }
    }
}

// MARK: - Custom Table View Cells

/**
 * Slider Table View Cell: Cell with slider control
 */
class SliderTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let valueLabel = UILabel()
    private let slider = UISlider()
    private var action: ((Float) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .systemBlue
        
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        
        [titleLabel, subtitleLabel, valueLabel, slider].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -8),
            
            slider.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            slider.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(title: String, subtitle: String?, value: Float, range: ClosedRange<Float>, action: @escaping (Float) -> Void) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        
        slider.minimumValue = range.lowerBound
        slider.maximumValue = range.upperBound
        slider.value = value
        
        updateValueLabel(value)
        self.action = action
    }
    
    @objc private func sliderChanged() {
        let value = slider.value
        updateValueLabel(value)
        action?(value)
    }
    
    private func updateValueLabel(_ value: Float) {
        valueLabel.text = String(format: "%.1f", value)
    }
}

/**
 * Switch Table View Cell: Cell with toggle switch
 */
class SwitchTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    private var action: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        [titleLabel, subtitleLabel, toggleSwitch].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(title: String, subtitle: String?, value: Bool, action: @escaping (Bool) -> Void) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        
        toggleSwitch.isOn = value
        self.action = action
    }
    
    @objc private func switchChanged() {
        action?(toggleSwitch.isOn)
    }
}

/**
 * Button Table View Cell: Cell with action button
 */
class ButtonTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var action: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        [titleLabel, subtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(title: String, subtitle: String?, style: UIAlertAction.Style, action: @escaping () -> Void) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        
        switch style {
        case .destructive:
            titleLabel.textColor = .systemRed
        case .cancel:
            titleLabel.textColor = .secondaryLabel
        default:
            titleLabel.textColor = .systemBlue
        }
        
        self.action = action
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            action?()
        }
    }
}

// MARK: - Storage Classes

/**
 * Calibration Settings Storage: Manages settings persistence
 */
class CalibrationSettingsStorage {
    static let shared = CalibrationSettingsStorage()
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "DogTVPlus_CalibrationSettings"
    
    private init() {}
    
    func saveSettings(_ settings: CalibrationSettings) {
        do {
            let encoded = try JSONEncoder().encode(settings)
            userDefaults.set(encoded, forKey: settingsKey)
            print("Calibration settings saved successfully")
        } catch {
            print("Failed to save calibration settings: \(error)")
        }
    }
    
    func loadSettings() -> CalibrationSettings? {
        guard let data = userDefaults.data(forKey: settingsKey) else {
            return nil
        }
        
        do {
            let settings = try JSONDecoder().decode(CalibrationSettings.self, from: data)
            print("Calibration settings loaded successfully")
            return settings
        } catch {
            print("Failed to load calibration settings: \(error)")
            return nil
        }
    }
    
    func clearSettings() {
        userDefaults.removeObject(forKey: settingsKey)
        print("Calibration settings cleared")
    }
}
#endif