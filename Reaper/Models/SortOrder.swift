enum SortOrder: String, CaseIterable, Identifiable {
    case threat = "Threat"
    case cpu = "CPU"
    case memory = "Memory"
    case name = "Name"

    var id: String { rawValue }
}
