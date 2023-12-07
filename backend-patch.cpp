namespace Poppler {
struct Document {
    enum RenderBackend {};
    void setRenderBackend(RenderBackend);
};
// TeXstudio sets splash as its default rendering backend. In order to use Cairo
// subpixel backend without patching TeXstudio, we can nullify its backend
// setting
void Document::setRenderBackend(RenderBackend) {}
}; // namespace Poppler
