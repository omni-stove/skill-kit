# @feature JSDoc rules

A `@feature` JSDoc is the catalog of what the app does from the user's point of view; tours of the app and agents answering what a feature does read it.

## Subjects

Put it on a component the user perceives as a feature: a UI they operate, or a screen, panel or tab that shows them information. Leave it off internal parts: layouts, reused confirmation dialogs and file inputs, state providers, and wrappers that only branch on what to render.

## Tags

| Tag | What to write |
| --- | --- |
| `@feature` | The feature's name. A UI part's name (panel, dialog, button) is not a feature name. |
| `@capabilities` | Short keywords for what it lets the user do, comma-separated. |
| `@behavior` | Sentences on what the user does (click, select, type, drag, switch) and what that achieves. Confirm the actual operation from the implementation's handlers. |
| `@airule` | Always `IMPORTANT: Update this JSDoc when modifying this component's functionality`. |

A description that ends at a visual or state change (open/close, highlight, color, icon) says nothing yet. Put prop names, state and flags into the user's words. `@capabilities` and `@behavior` do not repeat each other.

## Scope

Write only the features the file itself renders and operates. What a child component, a navigation target or a caller does belongs to that file. A parent that bundles, switches or passes through documents that bundling itself.

## Example

```
@feature 引用元の確認
@capabilities 引用箇所からの引用元表示, 複数引用元の一覧表示
@behavior 本文中の引用箇所をクリックすると、AI 回答や通話アシストが根拠とした引用元を確認でき、複数あるときは見比べて回答の根拠を突き合わせられる
@airule IMPORTANT: Update this JSDoc when modifying this component's functionality
```
