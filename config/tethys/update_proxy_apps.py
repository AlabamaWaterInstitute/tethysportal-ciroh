import yaml
import logging
import os
import subprocess

logging.basicConfig(format="%(asctime)s - %(message)s", level=logging.INFO)

script_dir = os.environ["TETHYS_PERSIST"]
portal_change_path = os.path.join(script_dir, "portal_changes.yml")


def add_proxy_app(proxy_app):
    name = proxy_app.get("name")
    endpoint = proxy_app.get("endpoint")
    logo_url = proxy_app.get("logo_url", "")
    description = proxy_app["description", ""]
    tags = proxy_app.get("tags", "")
    enabled = proxy_app.get("enabled", True)
    show_in_apps_library = proxy_app.get("show_in_apps_library", True)
    back_url = proxy_app.get("back_url", "")
    open_in_new_tab = proxy_app.get("open_in_new_tab", True)
    display_external_icon = proxy_app.get("display_external_icon", False)
    order = proxy_app.get("order", 0)
    try:
        subprocess.run(
            [
                "tethys",
                "proxyapp",
                "add",
                f"{name}",
                f"{endpoint}",
                f"{description}",
                f"{logo_url}",
                f"{tags}",
                f"{enabled}",
                f"{show_in_apps_library}",
                f"{back_url}",
                f"{open_in_new_tab}",
                f"{open_in_new_tab}",
                f"{display_external_icon}",
                f"{order}",
            ]
        )
        logging.info(f"proxy app {name} added successfully")
    except Exception as e:
        logging.error(f"proxy app {name} not added: {e}")
        return False


def add_proxy_apps():
    try:
        with open(portal_change_path) as portal_changes:
            ymlportal_changes = yaml.safe_load(portal_changes)
            proxy_apps = ymlportal_changes.get("proxy_apps", {})
            for proxy_app in proxy_apps:
                add_proxy_app(proxy_apps[proxy_app])

        logging.info(f"proxy apps added successfully")

    except Exception as e:
        logging.error(f"It was not possible to add all the proxy apps: {e}")


def update_proxy_app(proxy_app):
    name = proxy_app.get("name")
    endpoint = proxy_app.get("endpoint")
    logo_url = proxy_app.get("logo_url", "")
    description = proxy_app["description", ""]
    tags = proxy_app.get("tags", "")
    enabled = proxy_app.get("enabled", True)
    show_in_apps_library = proxy_app.get("show_in_apps_library", True)
    back_url = proxy_app.get("back_url", "")
    open_in_new_tab = proxy_app.get("open_in_new_tab", True)
    display_external_icon = proxy_app.get("display_external_icon", False)
    order = proxy_app.get("order", 0)
    try:
        update_result = subprocess.run(
            [
                "tethys",
                "proxyapp",
                "update",
                f"{name}",
                "--set",
                "name",
                f"{name}",
                "--set",
                "endpoint",
                f"{endpoint}",
                "--set",
                "description",
                f"{description}",
                "--set",
                "logo_url",
                f"{logo_url}",
                "--set",
                "back_url" f"{back_url}",
                "--set",
                "tags" f"{tags}",
                "--set",
                "enabled" f"{enabled}",
                "--set",
                "show_in_apps_library" f"{show_in_apps_library}",
                "--set",
                "open_in_new_tab" f"{open_in_new_tab}",
                "--set",
                "display_external_icon" f"{display_external_icon}",
                "--set",
                "order" f"{order}",
            ],
            capture_output=True,
        )

        if update_result.stdout in "Proxy app '{name}' was updated successfully":
            logging.info(f"proxy app {name} was updated successfully")

        if update_result.stdout in "Proxy app named '{name}' does not exist":
            add_proxy_app(proxy_app)

    except Exception as e:
        logging.error(f"proxy app {name} not updated: {e}")
        return False


def update_proxy_apps():
    try:
        with open(portal_change_path) as portal_changes:
            ymlportal_changes = yaml.safe_load(portal_changes)
            proxy_apps = ymlportal_changes.get("proxy_apps", {})
            for proxy_app in proxy_apps:
                update_proxy_app(proxy_apps[proxy_app])

        logging.info(f"proxy apps added successfully")

    except Exception as e:
        logging.error(f"It was not possible to add all the proxy apps: {e}")


def list_pxoxy_apps():
    list_pa = subprocess.run(["tethys", "proxyapp", "list"], capture_output=True)
    if list_pa.stdout == "Proxy Apps:":
        add_proxy_apps()
    else:
        update_proxy_apps()


def main():
    add_proxy_apps()


if __name__ == "__main__":
    main()
