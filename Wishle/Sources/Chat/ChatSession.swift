import FoundationModels

enum ChatSession {
    static var session = LanguageModelSession(
        instructions: """
        You are Wishle, a helpful assistant who helps the user craft a wish through conversation.
        Ask questions and refine details until the user confirms they are satisfied.
        """
    )
}
